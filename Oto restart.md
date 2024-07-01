Track Restart

```
screen -S restart```

```
nano stationd_auto_restart.sh```

```
#!/bin/bash

# Yeniden başlatma aralığını saniye cinsinden ayarlayın (örneğin, her 60 saniyede bir)
RESTART_INTERVAL=150

# Sonsuz döngü içinde çalışacak
while true; do
    echo "Servis yeniden başlatılıyor..."
    # Servisi yeniden başlat
    sudo systemctl restart stationd
    echo "Servis başarıyla yeniden başlatıldı."
    # Belirtilen süre kadar bekleyin
    sleep $RESTART_INTERVAL
done
```
```
chmod +x stationd_auto_restart.sh```
```
./stationd_auto_restart.sh```
