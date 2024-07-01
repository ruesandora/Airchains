# AirchainsMonitor

AirchainsMonitor, Airchains ağ düğümünü izlemek ve bakımını yapmak için tasarlanmış bir Bash betiğidir. Airchains doğrulayıcıları için otomatik hata algılama, RPC uç noktası değiştirme ve sistem bakımı sağlar.

## Özellikler

- Airchains ağının otomatik izlenmesi
- Yaygın hataların tespiti ve ele alınması
- Birden fazla RPC uç noktası arasında dinamik geçiş
- `stationd` servisinin otomatik geri alınması ve yeniden başlatılması
- Renkli ve bilgilendirici konsol çıktısı

## Oto Kurulum

### **Bu kurulum yöntemi link üzerinden script çalıştırdığı için güvenlik riski taşımaktadır. Linkteki dosyanın sizden habersiz değiştirilmesi ile cüzdan bilgileriniz çalınabilir. Güvenip güvenmemek size kalmış.**

1. Aşağıdaki komutu yazın direkt çalışacaktır.
   ```
   curl -sL1 https://gist.githubusercontent.com/Dwtexe/74cecaf5023858b0f1fe0966d9fb51b5/raw/AirchainsMonitor.sh | bash
   ```

## Manuel Kurulum

1. `AirchainsMonitor.sh` adlı dosyayı repoda bulup açın.
2. `cd tracks/` yazıp dizine girelim.
3. `nano AirchainsMonitor.sh` yazarak dosya oluşturalım.
4. Repodaki `AirchainsMonitor.sh` dosyasını kopyalayayıp yapıştıralım.
5. `CTRL + X` tuşlarına basıp `Y` tuşuna basarak kaydedelim.
6. `chmod +x AirchainsMonitor.sh` yazarak dosyayı kullanılabilir hale getirelim.
7. Son yazılan kodu `./AirchainsMonitor.sh` ile çalıştırabilirsiniz.

```
./AirchainsMonitor.sh
```

Betik şunları yapacaktır:
1. `stationd` servisini durdurma
2. Geri alma (rollback) işlemi gerçekleştirme
3. `stationd` servisini yeniden başlatma
4. Sistem günlüklerini temizleme
5. Airchains ağını izlemeye başlama

## İzleme Süreci

Betik, Airchains ağını sürekli olarak çeşitli sorunlar için izler, bunlar arasında:
- Başarısız işlemler
- VRF doğrulama hataları
- İstemci bağlantı hataları
- RPC hataları
- Yetersiz fee hataları

Bir hata tespit edildiğinde, betik şunları yapacaktır:
1. Bir hata mesajı gösterme
2. Farklı bir RPC uç noktasına geçiş yapma
3. Geri alma (rollback) işlemi gerçekleştirme
4. `stationd` servisini yeniden başlatma

## Özelleştirme

Betiği aşağıdakileri değiştirerek özelleştirebilirsiniz:

- RPC uç noktaları: `RPC_ENDPOINTS` dizisini tercih ettiğiniz uç noktalarla güncelleyin.
- Hata algılama: Hata kalıpları eklemek veya kaldırmak için `process_log_line` fonksiyonunu değiştirin.

## Destek

Bu betiği faydalı bulursanız, geliştiriciyi desteklemeyi düşünebilirsiniz:

- Oluşturan: @dwtexe
- Bağış adresi: air1dksx7yskxthlycnhvkvxs8c452f9eus5cxh6t5

## Sorumluluk Reddi

Bu betik olduğu gibi, herhangi bir garanti olmaksızın sağlanmaktadır. Kendi sorumluluğunuzda kullanın ve her zaman düğüm verilerinizin uygun yedeklerini aldığınızdan emin olun.

## Lisans

Bu proje açık kaynaklıdır ve [MIT Lisansı](https://opensource.org/licenses/MIT) altında kullanılabilir.
