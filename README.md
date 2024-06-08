<h1 align="center">Airchains</h1>

> UYARI : Her hangi bir hatada puanlarınızın kaybolmaması için kurulum aşamalarında verilen keyleri ve priv keyleri saklayın.

> Standart güncelleme ve gereksinimleri kuruyoruz.

#

<h1 align="center">Donanım</h1>

```
Minimum: 2 vCPU 4 RAM
Önerilen: 4vCPU 8 RAM
```
<h1 align="center">Kurulum</h1>

```console
# güncelleme
apt update && apt upgrade -y
sudo apt install -y curl git jq lz4 build-essential cmake perl automake autoconf libtool wget libssl-dev

# Go kurulumu
sudo rm -rf /usr/local/go
curl -L https://go.dev/dl/go1.22.3.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
source .bash_profile
```

```console
# Gerekli repoları çekiyoruz
git clone https://github.com/airchains-network/evm-station.git
git clone https://github.com/airchains-network/tracks.git
```

```console
# evmos ağımızın kurulumuna başlıyoruz, bu localde çalışan kendi ağımız.
cd evm-station
go mod tidy
```

```console
# Bu komutla kurulumu tamamlıyoruz.
/bin/bash ./scripts/local-setup.sh
```

# 

> Sonraki aşamalarda rpc lazım olacak, onun ayarını yapalım.

> En altta RPC kısmı şu şekilde olacak.

```
nano ~/.evmosd/config/app.toml
```

![image](https://github.com/ruesandora/Airchains/assets/101149671/588a02d0-f7e3-4c25-ac25-ffff281206eb)


> Böylece cosmos rpclerini public yapmayı öğrendiniz.


> Sistem dosyasının sağlıklı çalışabilmesi için bir env oluşturuyoruz.

```console
nano ~/.rollup-env
```

> İçerisine gerekli değişkenleri giriyoruz.

```console
# buradaki kod bloğunda değiştirmeniz bir yer yok.
CHAINID="stationevm_9000-1"
MONIKER="localtestnet"
KEYRING="test"
KEYALGO="eth_secp256k1"
LOGLEVEL="info"
HOMEDIR="$HOME/.evmosd"
TRACE=""
BASEFEE=1000000000
CONFIG=$HOMEDIR/config/config.toml
APP_TOML=$HOMEDIR/config/app.toml
GENESIS=$HOMEDIR/config/genesis.json
TMP_GENESIS=$HOMEDIR/config/tmp_genesis.json
        VAL_KEY="mykey"
```

> Servis dosyasını yazıyoruz. User kullanıyorsanız `root` kısmını ona göre değiştirin.

```console
# tek komut tüm bloğu copy paste yapabilirsiniz yavrularım
sudo tee /etc/systemd/system/rolld.service > /dev/null << EOF
[Unit]
Description=ZK
After=network.target

[Service]
User=root
EnvironmentFile=/root/.rollup-env
ExecStart=/root/evm-station/build/station-evm start --metrics "" --log_level info --json-rpc.api eth,txpool,personal,net,debug,web3 --chain-id stationevm_9000-1
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
```

> Servisleri güncelleyip başlatıyoruz.

```
sudo systemctl daemon-reload
sudo systemctl enable rolld
sudo systemctl start rolld
sudo journalctl -u rolld -f --no-hostname -o cat
```
> Logların aktığını görmelisiniz. 

![image](https://github.com/ruesandora/Airchains/assets/101149671/64137490-6b3b-4678-ae26-81c90dd1f952)


#


Bu komut bize private key verecek, saklıyoruz.
```console
/bin/bash ./scripts/local-keys.sh
```

#

DA layer olarak eigenlayer kullanacağız. Bunun için key gerekiyor, binary indirip çalışması için izin veriyoruz.
Resmi dökümanda celestia, avail kurulumları da var onlara da bakabilirsiniz.
Mock, yani sahte DA da kullanabilirsiniz (mock ile bir süre puan kazanılmasına izin vereceklermiş)
Şu an testnette sonradan DA değiştirilmiyor, güncellemeyle bunu mümkün kılacaklarını söylediler.

Benim EigenDA seçme nedenim en kolay Celestia ve Eigen olması (token de bulması kolay), Celestia ezbere biliyoruz - bu sefer Eigen olsun.

#

```console
cd $HOME
wget https://github.com/airchains-network/tracks/releases/download/v0.0.2/eigenlayer
mkdir -p $HOME/go/bin
chmod +x $HOME/eigenlayer
mv $HOME/eigenlayer $HOME/go/bin
```

```console
# `CUZDANADI` değiştirin ve çıktıda size verilen ECDSA Private Keyi saklayın. 
# Ctrl+c ile kapatın enterlayın ve verilen diğer `public hex` kenara not edin lazım olacak.
# Verilen 0x evm adresine her ihtimale karşı 0.5 eth atın holesky ağında.

eigenlayer operator keys create --key-type ecdsa CUZDANADI
```

> Şimdi track ve station kısmına geçiyoruz. 

```console
cd $HOME
cd tracks
go mod tidy
```

> tracks klasörü içindeyken aşağıdaki kodu başlatıyoruz. ```PUBLICHEX``` biraz önce aldığımız public key olacak. 

> MONIKER (validatör ismi) değiştirebilirsiniz kafanıza göre. 

```console
go run cmd/main.go init --daRpc "disperser-holesky.eigenda.xyz" --daKey "PUBLICHEX" --daType "eigen" --moniker "MONIKER" --stationRpc "http://127.0.0.1:8545" --stationAPI "http://127.0.0.1:8545" --stationType "evm"
```

#

> Çıktı şu şekilde olacak

![tg_image_2547108070](https://github.com/ruesandora/Airchains/assets/101149671/463e6802-ab58-4e3b-86d2-8ba8c1c15819)

# 

> Şimdi tracker adresi oluşturuyoruz. `TRACKERCUZDAN` değiştirin.

> Çıktıyı yedek alın, air prefixli cüzdanla [discordda](https://discord.gg/airchains) `switchyard faucet` kanalından token alın.

```console
go run cmd/main.go keys junction --accountName TRACKERCUZDAN --accountPath $HOME/.tracks/junction-accounts/keys
```

> Sonra proveri çalıştırıyoruz.

```console
go run cmd/main.go prover v1EVM
```

> Şimdi bize node id lazım, bunu da şurdan alıyoruz.

```console
# ctrl w ile node id aratabilirsiniz, en aşağı gidip biraz yukarıda
nano ~/.tracks/config/sequencer.toml
```

![image](https://github.com/ruesandora/Airchains/assets/101149671/8be10bf2-c873-4e97-a40d-2dd148854991)

#

> Aşağıdaki kodda

> `TRACKERCUZDAN` yukarda yazdığınız adı

> `TRACKERCUZDAN-ADRESI` buna da air cüzdanı 

> `IP` ip adresiniz

> `NODEID` sequencer.toml dan temin ettiğimiz node id olacak


```console
go run cmd/main.go create-station --accountName TRACKERCUZDAN --accountPath $HOME/.tracks/junction-accounts/keys --jsonRPC "https://airchains-testnet-rpc.cosmonautstakes.com/" --info "EVM Track" --tracks TRACKERCUZDAN-ADRESI --bootstrapNode "/ip4/IP/tcp/2300/p2p/NODEID"
```

#

> Stationu kurduk, şimdi bunu servisle çalıştıralım. 

> Servis çalıştırmak istemeyenler screen açıp tracks klasöründe `go run cmd/main.go start` komutunu çalıştırabilirler.

```console
sudo tee /etc/systemd/system/stationd.service > /dev/null << EOF
[Unit]
Description=station track service
After=network-online.target
[Service]
User=root
WorkingDirectory=/root/tracks/
ExecStart=/usr/local/go/bin/go run cmd/main.go start
Restart=always
RestartSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

```console
sudo systemctl daemon-reload
sudo systemctl enable stationd
sudo systemctl restart stationd
sudo journalctl -u stationd -f --no-hostname -o cat
```

<h1 align="center">Kurulum tamam ama?</h1>

Kurulum işlemleri bu kadar. Ama şu an puan kazanmıyorsunuz. 
Tracker cüzdanınızın mnemoniclerini leap wallet import edip https://points.airchains.io/ connect diyoruz 
Dashboardda stationu ve puanınızı görebilirsiniz. 
Henüz tx yapmadığımız için 100 point pending görünecek. Bunun sebebi şu, puan kazanmanız için pod çıkarmanız lazım.
Pod 25txten oluşan bir paket gibi düşünebilirsiniz. Her 25tx 1 pod çıkaracak ve bu işlemlerden 5 puan kazanacaksınız. 
İlk kurulumdaki 100 puan, ilk poddan sonra aktif olacak.

Bunun için de şunu yapıyoruz
İlk başta `bin/bash ./scripts/local-keys.sh` komutuyla bir priv key aldık ve rpc ayarı yapmıştık.
Metamaska bu priv keyi import ediyoruz, ağ ekle kısmında da 

```
rpc http://IP:8545

id 9000

ticker tEVMOS
```

girip okeyliyoruz.

Ayrıca rpc'ye bağlanabilmek için 8545 numaralı portu açıyoruz o da şu komutla 
```
sudo ufw allow 8545
```
Buradan artık kontrat mı deploy edersiniz, manuel tx mi kasarsınız size kalmış.

Track işleminde rpc hatası alanlar rollback yapmayı denesinler. Bazen 1 bazen 3 rollback işlemiyle sorun çözülüyor.
Kaç kez rollback yapmak istiyorsanız ``go run cmd/main.go rollback`` komutunu o kadar çalıştırın, her seferinde çıktıyı bekleyin.

```
systemctl stop stationd
cd tracks
git pull
go run cmd/main.go rollback
sudo systemctl restart stationd
sudo journalctl -u stationd -f --no-hostname -o cat
```


Hadi sağlıcakla.

<img width="560" alt="Ekran Resmi 2024-06-07 14 18 52" src="https://github.com/ruesandora/Airchains/assets/101149671/8aad779e-85f2-44dd-8c05-0131ea7f089a">

