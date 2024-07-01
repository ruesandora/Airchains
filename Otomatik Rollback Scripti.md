<h1 align="center">İstasyon Otomatik Başlatma</h1>

Airchain loglarının aktığı screen dışında yeni bir screen açıyoruz.
```
screen -S rollback
```
Bu screen içerisinde yeni bir dosya oluşturuyoruz.
```
nano check_log_and_fix.sh
```
Dosya içine  buradaki scipti kopyalayıp yapıştırıyoruz ve ctrl x+y ile kayıt edip çıkıyoruz.

```
#!/bin/bash

# Define service name and log search strings
service_name="stationd"
error_patterns=(
    "with gas used"
    "ERR Error in SubmitPod Transaction Error="
    "Failed to get transaction by hash: not found"
    "Switchyard client connection error"
    "Failed to Init VRF" 
)
restart_delay=180  # Restart delay in seconds (3 minutes)

echo "Script started and it will rollback $service_name if needed..."

while true; do
  # Get the last 10 lines of service logs
  logs=$(systemctl status "$service_name" --no-pager | tail -n 10)

  # Check for error patterns in the logs
  error_found=false
  for pattern in "${error_patterns[@]}"; do
    if [[ "$logs" =~ $pattern ]]; then
      error_found=true
      break
    fi
  done

  # If an error pattern is found, perform rollback and restart
  if $error_found; then
    echo "Found error in logs, stopping $service_name..."
    systemctl stop "$service_name"
    cd ~/tracks

    echo "Service $service_name stopped, starting rollback..."
    go run cmd/main.go rollback
    go run cmd/main.go rollback
    go run cmd/main.go rollback
    echo "Rollback completed, starting $service_name..."
    systemctl start "$service_name"
    echo "Service $service_name started"
  fi

  # Sleep for the restart delay
  sleep "$restart_delay"
done

```

Daha sonra bu dosyaya izin vermek için
```
chmod +x check_log_and_fix.sh
```

İzin verdikden sonra sciptimizi başlatabiliriz.

```
./check_log_and_fix.sh
```
Airchain logları başka bir screende akarken bu açtığımız screen ise onu kontrol ederek benim tespit ettiğim 3 hatada otomatik rollback atacaktır.

> NOT : Arada veren hatalar için tekrar başlatma yapmıyor.
