
# Airchains İstasyon Taşıma

Bugün sizlere Airchains istasyonumuzu tamamiyle farklı bir sunucuya (Farklı bir IP, farklı bir firma vs.) taşımayı anlatacağım.

Öncelikle sizlere şunu söyleyeyim;

Herhangi bir repo/docs bulamadığım için tamamen deneme yanılma yöntemiyle yaptığım bir olaydı ve bugün itibariyle (20.07.2024) 3 gündür sorunsuz şekilde çalışıyor. 

Bunu söylemememin sebebi de gerekli veya gereksiz dosya almış olabilirim ama bence gerekliydi, hiç bir sorun yaşamadım. Aksine ben Armm64 mimarisinden Amd mimarisine geçiş yaptım ve herhangi bir sorun yaşamadım. Aranızda mimari değiştirecek olan da varsa lütfen telegram üzerinden bana (Dtractus) ulaşın, sadece minik farklı bir işlem yapacağız.

Lütfen taşıma tamamlandı diye ilk sunucunuzu kapatmayın, bırakın 2-3 gün yeni sunucunuzu izleyin. Sorun yok, her şeyiniz harika çalışıyorsa kapatırsınız. Çok fazla sorun yaşayıp pes etmek istersenizde bu sayede uğraşmadan ilk sunucunuzda durdurduğumuz servis dosyalarını tekrar aktif hale getirip, eski haliyle devam edebilirsiniz :)

Son bir uyarı, sizlere 2. sunucunuzda diye belirtmediğim sürece tüm işlemler 1. sunucuda yapılacak. 2. sunucu olduğunu belirttiğim zaman taşıyacağınız yeni sunucuda işlem yapabilirsiniz. 

Bu kadar ön anlatım yeterli diye düşünüyor, işlemleri anlatmaya geçiyorum;



## Taşıma aşaması için hazırlık

Öncelikle diğer sunucuya geçişte sorun yaşamamak için çalışan stationd ve rolld'mizi durdurmamız gerekiyor.

Aşağıdaki komutla öncelikle rolld'yi, daha sonra stationd'yi durduruyoruz.

```bash
  sudo systemctl stop rolld && sudo systemctl stop stationd
```
  Lütfen durduğundan emin olun, çünkü bazılarınızın stationd'si durmuyor. Komutu kullandıktan sonra bitmesini bekleyin, acele etmeye gerek yok. Aşağıdaki komutlarla durup durmadığına bakabilirsiniz;

  Rolld kontrolü için 
```bash
  sudo journalctl -u rolld -f --no-hostname -o cat
```

  Stationd kontrolü için 
```bash
  sudo journalctl -u stationd -f --no-hostname -o cat
```

Durduğundan eminsek birde sunucumuzda yeterli olduğundan emin olalım, çünkü yedekleme işlemi için bize belirli bir alan gerekli. Ortalamaya vurursak 10 GB alan yeterli diye düşünmekteyim. Alan kontrolü için aşağıdaki komutu kullanalım;

```bash
  df -h
```

Komuttan sonra genelde dev/sda1 sizin alanınızı gösterir. Avail hizasındaki kısım sizlerin boş alanını temsil eder.


Yukarıdaki kısımlarıda düzenli okuyup, her şeyi adım adım yerine getirdiysek 2. aşamaya, yani yedekleme aşamasına geçelim.

## Yedekleyeceğimiz Dosyaları Hazırlayalım

Öncelikle sunucumuzun root dizininde olduğumuzdan emin olalım. Bunu kodlada sağlayabiliriz fakat daha sonra kafanız karışmasın, ilerleyen aşamada unutup sorun yaşamayın diye bu kısmı eklemek istedim. Root dizininde olduğumuzdan emin olalım.

```bash
  cd
```
Evet sadece basit iki harf ile nerede olursanız olun root dizinine geçiyorsunuz.
Şimdi kendimize aşağıdaki kod ile dosyalarımızı yedekleyeceğimiz bir klasör oluşturalım;

```bash
  mkdir -p backup
```
Dosyamızı oluşturduk, şimdi içerisine bizim için gerekli (bence gerekli) dosyalarımızı alalım. 

```bash
  cp -r $HOME/evm-station $HOME/backup/ && \
  cp -r $HOME/tracks $HOME/backup/ && \
  cp -r $HOME/.eigenlayer $HOME/backup/ && \
  cp -r $HOME/.evmosd $HOME/backup/ && \
  cp -r $HOME/.tracks $HOME/backup/ && \
  cp -r $HOME/go $HOME/backup/root_go && \
  cp $HOME/.rollup-env $HOME/backup/
```
Bu işlem biraz uzun sürebilir, sakin olun, ekranda akanları izleyebilirsiniz.

İzleme işlemimiz bittiyse, hadi bu dosyalarımızı sıkıştıralım;


```bash
  tar -czvf dtractus_backup.tar.gz -C $HOME/backup .
```
Sıkıştırma işlemi de yine dosya boyutuna göre biraz sürebilir, ekranda göreceksiniz zaten. İşlemleri neredeyse yarıladık.

Diğer sunucumuza geçmeden önce bu dosyamızı indirmek için kendimize minik bir HTTP sunucusu oluşturalım ki upload işlemleri ile vakit kaybetmeyelim. Aşağıdaki kodu direkt çalıştırın, sunucunuzda Python kurulu değilse endişelenmeyin, olmayanlar için bu komutun altına python kurulumunu da yazacağım.

Aşağıdaki kodla bir HTTP sunucusu açalım;

```bash
  cd && python3 -m http.server 8000
```

Yukarıdaki kodda hata alıyorsanız muhtemelen sunucunuzda Python kurulu değildir, endişelenmeyin ve aşağıdaki kodu çalıştırarak yükleyin ve yükleme bitince tekrar üstteki komut ile HTTP sunucusunu açın;

```bash
  sudo apt install python3 python3-pip -y
```

Tebrikler! İlk sunucumuzda işimizi bitirdik. 

## Yeni Sunucumuzda Hazırlıklarımızı Yapalım

Evet, ikinci sunucumuzda öncelikle gereksinimlerimizi yükleyelim.

Sunucumuzu güncelleyelim ;

```bash
  sudo apt update && sudo apt upgrade -y 
```

Sunucumuza gerekli paketlerimizi kuralım;


```bash
  sudo apt install -y curl git jq lz4 build-essential cmake perl automake autoconf libtool wget libssl-dev
```

Sunucumuza GO kurulumunu yapalım, eigenlayer binary'sini indirip yerine koyalım;

```bash
  sudo rm -rf /usr/local/go && \
  curl -L https://go.dev/dl/go1.22.3.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local && \
  echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && \
  source $HOME/.bash_profile && \
  wget https://github.com/airchains-network/tracks/releases/download/v0.0.2/eigenlayer && \
  mkdir -p $HOME/go/bin && \
  chmod +x $HOME/eigenlayer && \
  mv $HOME/eigenlayer $HOME/go/bin
```

Go kurulumumuzda hazır, şimdi sıkıştırdığımız dosyayı yeni sunucumuza indirelim.

Lütfen aşağıdaki kodda ESKİ SUNUCUNUZUN IP'sini (HTTP Sunucusu oluşturduğumuz sunucu ip'si) yazıp, yeni sunucuda kullanın;

```bash
  wget http://ESKISUNUCUIP:8000/dtractus_backup.tar.gz -O $HOME/dtractus_backup.tar.gz

```

Evet boşuna upload vesaire işlemiyle uğraşmadan direkt sıkıştırılmış dosyamızı yeni sunucumuza kolaylıkla ve hızlıca indirmiş olduk. Şimdi yeni sunucumuza da bir backup dosyası oluşturalım;

```bash
  mkdir -p backup
```

Şimdi oluşturduğumuz bu dosyanın içerisine sıkıştırdığımız dosyaları çıkartalım;

```bash
  tar -xzvf $HOME/dtractus_backup.tar.gz -C $HOME/backup
```

Eveeet. Şimdi geldik dosyalarımızı yerlerine göndermeye. Öncelikle ana dizinimizde olanları yollayalım;

```bash
  mv $HOME/backup/evm-station $HOME/evm-station && \
  mv $HOME/backup/tracks $HOME/tracks && \
  mv $HOME/backup/.eigenlayer $HOME/.eigenlayer && \
  mv $HOME/backup/.evmosd $HOME/.evmosd && \
  mv $HOME/backup/.tracks $HOME/.tracks && \
  mv $HOME/backup/.rollup-env $HOME/.rollup-env
```

Şimdide go paketlerimizi olması gereken yere gönderelim;

```bash
  sudo mkdir -p $HOME/go/pkg && sudo cp -r $HOME/backup/root_go/pkg/* $HOME/go/pkg/
```

Bunlarıda gönderdikten sonra, gerekli olup olmadığını bilmesemde garantiye almak amaçlı ilgili dosyalarda eski sunucu ip'mizi, yeni sunucumuzun ip'si ile değiştirmemiz gerektiğini düşünüyorum. Bunu sizin için en basit hale getirdim.

Bu komutu dilerseniz önce notepad tarzı bir yerde düzenleyin, daha sonra terminale geçirin. Hata esnasında düzeltilebilir fakat kendinizi yormayın.

Bize eski sunucu ip'miz ve yeni sunucu ip'miz gerek. Lütfen tırnak işaretlerini kaldırmayın ve aşağıdaki eski_ip_adresi ve yeni_ip_adresi kısımlarını değiştirin! (2 tane sadece)

```bash
  OLD_IP="eski_ip_adresi" && NEW_IP="yeni_ip_adresi" && find $HOME/.evmosd/config/gentx -type f -name "*.json" -exec sed -i "s/$OLD_IP/$NEW_IP/g" {} + && sed -i "s/$OLD_IP/$NEW_IP/g" $HOME/.evmosd/config/genesis.json && sed -i "s/$OLD_IP/$NEW_IP/g" $HOME/.tracks/config/sequencer.toml
```

Tırnak işaretlerini kaldırmadan sadece üstteki iki yeri değiştirdiyseniz ve komutu kullandıysanız bunu da kolayca halletmiş olduk. Şimdi sıra geldi servis dosyalarını oluşturmaya ve çalıştırmaya;

Tamamını kopyalayıp terminale yapıştırabilirsiniz fakat root değil farklı bir şey kullanıyorsanız root olan yerleri değiştirin;

```bash
sudo tee /etc/systemd/system/rolld.service > /dev/null << EOF
[Unit]
Description=ZK
After=network.target

[Service]
User=root
EnvironmentFile=/root/.rollup-env
ExecStart=/root/evm-station/build/station-evm start --metrics "" --log_level info --json-rpc.api eth,txpool,personal,net,debug,web3 --chain-id "stationevm_1234-1"
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

Stationd içinde servis dosyamızı hazır edelim. Aynı şekilde tamamını kopyalayıp terminale yapıştırabilirsiniz fakat root değil farklı bir şey kullanıyorsanız root olan yerleri değiştirin;

```bash
sudo tee /etc/systemd/system/stationd.service > /dev/null << EOF
[Unit]
Description=station track service
After=network-online.target

[Service]
User=root
WorkingDirectory=/root/tracks/
ExecStart=/root/go/bin/go run /root/tracks/cmd/main.go start
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```

Evet, servis dosyalarımızı da hazırladık, şimdi geldi çalıştırmaya. Öncelikle sadece rolld'yi çalıştıracağız ve bir problem olup olmadığını göreceğiz;


```bash
  sudo systemctl daemon-reload && sudo systemctl enable rolld && sudo systemctl start rolld && sudo journalctl -u rolld -f --no-hostname -o cat
```

Bu komut servis dosyalarını yenileyip, rolld'yi aktif edip, çalıştırıp bize logları gösterecek. Kodların çalıştığını gözlemleyin, exit code vermesin. Exit code alırsanız telegramda grupta beni etiketleyerek (dtractus) sorabilirsiniz.

Her şey başarılı ise artık stationd'mizi de çalıştıralım ;

```bash
  sudo systemctl enable stationd && sudo systemctl start stationd && sudo journalctl -u stationd -f --no-hostname -o cat
```

Başarıyla stationd'mizi de çalıştırdık. Umuyorum ki hiç bir problem yaşamadan kurulumu tamamladınız ve her şey sorunsuz çalışıyor.

Herhangi bir yerde sorun yaşamanız halinde lütfen ama lütfen telegramda özelden yazmak yerine gruptan beni etiketleyerek sorunuzu sorun. 