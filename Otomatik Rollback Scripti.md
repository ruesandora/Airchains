<h1 align="center">İstasyon Otomatik Başlatma</h1>

Airchain loglarının aktığı screen içinde bir dosya oluşturuyoruz.
```
nano check_log_and_fix.sh
```
Dosya içine  buradaki scipti kopyalayıp yapıştırıyoruz ve ctrl x+y ile kayıt edip çıkıyoruz.

```
#!/bin/bash

# Log dosyası
LOG_FILE="/path/to/your/log/file.log"

# Log akışının başarılı olup olmadığını kontrol eden fonksiyon
check_log_flow() {
    # Belirli bir kelime veya desen için log dosyasını kontrol edebilirsiniz
    grep -q "Successfully generated  Unverified proof" "$LOG_FILE"
}

# Log akışını kontrol et
if ! check_log_flow; then
    # Log akışı bozulmuşsa yapılacak işlemler
    echo "Log akışı bozuldu, işlemler başlatılıyor..."
    
    # stationd servisini durdur
    systemctl stop stationd
    
    # Servisin tamamen durduğundan emin ol
    while systemctl is-active --quiet stationd; do
        sleep 1
    done
    
    # rollback işlemi
    go run cmd/main.go rollback
    
    # stationd servisini yeniden başlat
    sudo systemctl restart stationd
    
    # Log akışını takip et
    sudo journalctl -u stationd -f --no-hostname -o cat
else
    echo "Log akışı normal, hiçbir işlem yapılmadı."
fi
```

Daha sonra bu dosyaya izin vermek için
```
chmod +x check_log_and_fix.sh
```

Ve hata algıladığında otomatik rollback yapan scriptimizi başlatıyoruz.
```
./check_log_and_fix.sh
```


> UYARI : Her hata aldığında tek bir kere rollback atacaktır. Bu sayıyı isteyen dosyayı kaydetmeden rollback komutunu fazladan yazarak kendi ayarlayabilir . Ben kendim için %90 tek rollback ile çözdüğüm için 1 kere yazdım . Garantici olmak isteyenler 3 kere yazabilir.
> NOT : Arada veren hatalar için tekrar başlatma yapmıyor.
