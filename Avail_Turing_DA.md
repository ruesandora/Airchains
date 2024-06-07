<h1 align="center">Airchain Create an EVM ZK Rollup for Avail DA</h1>

> WARNING: To ensure that your points are not lost in case of any errors, store the keys and private keys provided during the installation steps.

> We are installing standard updates and requirements.

#

<h1 align="center">Hardware</h1>

```
Minimum: 2 vCPU 4 RAM
Recommended: 4vCPU 8 RAM
```
<h1 align="center">Intallation</h1>

```console
# Updating
apt update && apt upgrade -y
sudo apt install -y curl git jq lz4 build-essential cmake perl automake autoconf libtool wget libssl-dev

# Installing Go 
wget https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile
echo 'export GOROOT=/usr/local/go' >> $HOME/.bash_profile
echo 'export GOPATH=$HOME/go' >> $HOME/.bash_profile
echo 'export GO111MODULE=on' >> $HOME/.bash_profile &&  . $HOME/.bash_profile
rm -rf go1.22.0.linux-amd64.tar.gz
```

```console
#  Downloading the necessary repositories
git clone https://github.com/airchains-network/evm-station.git
git clone https://github.com/airchains-network/tracks.git
```

```console
# We are starting the setup of our Evmos network, which is our own network running locally.
cd evm-station
go mod tidy
```

```console
# We are completing the installation with this command.
/bin/bash ./scripts/local-setup.sh
```

# 

> In the next steps, we will need RPC, let's configure that.

> The RPC section at the bottom will be as follows.

```
nano ~/.evmosd/config/app.toml
```

![image](https://github.com/ruesandora/Airchains/assets/101149671/588a02d0-f7e3-4c25-ac25-ffff281206eb)


>  This way, you have learned how to make Cosmos RPCs public.


> We are creating an environment for the system file to function properly.

```console
nano ~/.rollup-env
```

> We enter the necessary variables into it.

```console
# There is nothing to change in the code block here.
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

> We are writing the service file. If you are using the User, adjust the `root` part accordingly.

```console
# You can copy and paste the entire block with just one command
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

> We update and start the services.

```
sudo systemctl daemon-reload
sudo systemctl enable rolld
sudo systemctl start rolld
sudo journalctl -u rolld -f --no-hostname -o cat
```
> You should see the logs flowing.

![image](https://github.com/ruesandora/Airchains/assets/101149671/64137490-6b3b-4678-ae26-81c90dd1f952)


#


This command will give us a private key, which we should store securely.
```console
/bin/bash ./scripts/local-keys.sh
```

#

We will use Avail Turing as the DA layer.
You can also use a mock DA (mock will allow earning points for a period of time).
Currently, on the testnet, the DA cannot be changed later, but they said they will make this possible with an update.


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


