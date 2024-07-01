# AirChains | RPC Hatası'nı Düzeltmek için Script

Bu script, log dosyamızda **"RPC hatası"** ve **"Switchyard client connection error"** hatası aldığımız anda tetiklenerek **rollback** işlemi gerçekleştirecek ve hatanın giderilmesini sağlayacaktır.

---

Bu scripti oluşturmaya başlamadan önce yapılması gereken bazı işlemler var.
---
**Lütfen okuyun:**

"stationd" servis dosyasını çalıştırdığımız (yani `sudo journalctl -u stationd -f --no-hostname -o cat` komutu ile logların aktığı) "air" isminde bir screen oturumumuz halihazırda mevcut (node kurulumu esnasında screen'e farklı bir isim verdiyseniz, sonraki adımlarda "air" yerine kendi screen adınızı kullanınız).

RPC hatasını düzeltmek için çalıştıracağımız scripti ise "autorestart" isminde ayrı bir screen oturumu içerisinde çalıştıracağız.

Ancak burada şöyle bir problem doğuyor: Logların aktığı "air" isimli screen'in, logları tuttuğu bir log dosyası yok. Dolayısıyla, RPC hatasını düzeltmek için oluşturacağımız script, logları takip edemiyor ve devreye girmesi için, algılaması gereken hata mesajlarını algılayamıyor. Dolayısıyla öncelikle bu sorunu çözmemiz gerekiyor.

**Bu sorunu gidermek için aşağıdaki adımları izleyeceğiz;**

Öncelikle logların aktığı screen oturumunu, 'logları kaydedecek şekilde' yeniden oluşturmamız gerekiyor:

**1- Varolan "air" screeni'ni silelim:**

*(Servis dosyasını çalıştırdığınız screen ismi farklıysa "air" yerine kendi screen adınızı girmelisiniz)*

```
screen -XS air quit
```
---
**2- Logları kaydedecek şekilde (-L seçeneği ile), "air" isminde yeni bir screen oturumu açalım:**
```
screen -S air -L
```
---
**3- -L seçeneği ile açtığımız screen, default olarak screenlog.0 isminde bir dosya oluşturmuş olmalı. (Dosya yolu: /root/screenlog.0)**

*(Bu dosya, script oluştururken işimize yarayacak)*

---
4- Yeni oluşturduğumuz "air" screen'inden Ctrl a+d ile çıkarak ana dizine gelelim.

---

### Yukarıdaki adımları tamamladıysak, script dosyasını oluşturmaya başlayabiliriz
---

## 1- Betik Dosyasını Oluşturma:
Betik dosyasını oluşturalım:
```
nano /root/restart_stationd.sh
```
Aşağıdaki içeriği 'değişiklik yapmadan' olduğu gibi yapıştıralım ve Ctrl x+y ile kaydederek çıkalım:
```
#!/bin/bash

LOG_FILE="/root/screenlog.0"
ERROR_MSGS=("rpc error: code = Unknown desc = rpc error: code = Unknown desc = failed to execute message; message index: 0: rpe error: code = Unavailable desc = incorrect pod number" "rpc error: code = Unknown desc" "Switchyard client connection error")

echo "Betik başlatılıyor..."
while true; do
    echo "Loglar kontrol ediliyor..."
    # Logları kontrol et
    tail -n 50 $LOG_FILE > /root/temp_log.log  # Son 50 satırı geçici bir dosyaya yaz
    for ERROR_MSG in "${ERROR_MSGS[@]}"; do
        echo "Hata mesajı aranıyor: $ERROR_MSG"
        if grep -q "$ERROR_MSG" /root/temp_log.log; then
            echo "Hata tespit edildi: $ERROR_MSG"
            systemctl stop stationd
            cd /root/tracks
            /usr/local/go/bin/go run cmd/main.go rollback
            systemctl restart stationd
            echo "stationd servisi yeniden başlatıldı"
            break
        fi
    done
    # 30 saniye bekle
    sleep 30
done
```

## 2- Betik Dosyasına Çalıştırma İzni Verme:
```
chmod +x /root/restart_stationd.sh
```

## 3- Betiği Servis Olarak Ayarlama:
Bir systemd servis dosyası oluşturalım ve betiği bir sistem servisi olarak ayarlayalım. Bu sayede betik sürekli olarak çalışacak ve hatayı algıladığında gerekli işlemleri yapacak.
```
sudo nano /etc/systemd/system/restart_stationd.service
```
Aşağıdaki içeriği 'değişiklik yapmadan' olduğu gibi yapıştıralım ve Ctrl x+y ile kaydederek çıkalım:
```
[Unit]
Description=Restart stationd service on error
After=network.target

[Service]
User=root
ExecStart=/root/restart_stationd.sh
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

## 4- Servisi Etkinleştirme ve Başlatma:
Autorestart isminde yeni bir screen oluşturalım:
```
screen -S autorestart
```
Servis dosyasını etkinleştirip başlatalım:
```
sudo systemctl daemon-reload
sudo systemctl enable restart_stationd.service
sudo systemctl start restart_stationd.service
```
Bu adımlar sonrasında, restart_stationd servisi logları sürekli olarak izleyecek ve belirtilen hata mesajını algıladığında otomatik olarak gerekli işlemleri yaparak node'unu yeniden başlatacaktır. Bu sayede, hatayı fark etmediğimiz durumlarda bile sistem otomatik olarak kendini toparlayabilecektir.

---

# Script silme:
```
sudo systemctl stop restart_stationd.service
sudo systemctl disable restart_stationd.service
```
```
sudo rm /etc/systemd/system/restart_stationd.service
```
```
sudo systemctl daemon-reload
```
```
rm /root/restart_stationd.sh
```
