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
# There is nothing to change ın the code block here.
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
# You can copy and paste the entire block with just one command.
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
git clone https://github.com/availproject/availup.git
cd availup
/bin/bash availup.sh --network "turing" --app_id 36
# Close with Ctrl+c, press Enter
```
![image](https://github.com/ahmkah/Airchains/assets/99053148/bbff7a2e-d2a9-42aa-ac23-563e01e37791)

> We are writing the service file. If you are using the User, adjust the `root` part accordingly.

```console
# You can copy and paste the entire block with just one command.
sudo tee /etc/systemd/system/availd.service > /dev/null <<'EOF'
[Unit]
Description=Avail Light Node
After=network.target
StartLimitIntervalSec=0

[Service]
User=root
Type=simple
Restart=always
RestartSec=120
ExecStart=/root/.avail/turing/bin/avail-light --network turing --app-id 36 

[Install]
WantedBy=multi-user.target
EOF
```
> We update and start the services.

```
systemctl daemon-reload 
sudo systemctl enable availd
sudo systemctl start availd
sudo journalctl -u availd -f --no-hostname -o cat
```
![image](https://github.com/ahmkah/Airchains/assets/99053148/364e88b4-d8eb-4e16-a5f9-abcf7c3c8482)


```console
# Inside the file `~/.avail/identity/identity.toml`, you will find the Mnemonics of your Avail wallet. Copy and store these words. 
# Close with Ctrl+c, press Enter, and make a note of the other `Avail-Mnemonics` given as they will be needed.
# Add the copied Mnemonics to Polkadot.js or Talisman wallet, get your wallet address on the Avail Turing network and receive tokens from the faucet.

 Avail-Faucet (https://faucet.avail.tools/)
```

> We are now moving on to the track and station section.

```console
cd $HOME
cd tracks
go mod tidy
```

> When we are inside the `tracks` folder, we start the following code. 
> Enter the validator name `<moniker-name>`. Do not include <>
> `daKey = <Avail-Mnemonic>`You can obtain your Avail mnemonics with `nano ~/.avail/identity/identity.toml`. Do not include <>

![image](https://github.com/ahmkah/Airchains/assets/99053148/65b18e53-8084-497f-8efa-51eb9f162d2f)
```console
avail_secret_uri = 'vessel spirit suggest harvest enjoy sort across tower round gossip topic clown true bottom pudding build zone subway proud forum border taxi gauge donor'
```
```console
go run cmd/main.go init --daRpc "http://127.0.0.1:7000" --daKey "<Avail-Mnomanic>" --daType "avail" --moniker "<moniker-name>" --stationRpc "http://127.0.0.1:8545" --stationAPI "http://127.0.0.1:8545" --stationType "evm"
```

#

> The output will be as follows.

![image](https://github.com/ahmkah/Airchains/assets/99053148/7db7471e-e8ad-40a0-8975-513f6e0dee43)


# 

> Now we are creating a tracker address. Please replace `<moniker-name>`.

> Take a backup of the output, and receive tokens from the channel with a wallet prefixed with 'air' [discord](https://discord.gg/airchains) `switchyard faucet` .

```console
go run cmd/main.go keys junction --accountName <moniker-name> --accountPath $HOME/.tracks/junction-accounts/keys
```

> Then we run the prover.

```console
go run cmd/main.go prover v1EVM
```

> Now we need the node id, which we obtain from here.

```console
# You can search for the node id with Ctrl + W, go to the bottom, and scroll up a bit.
nano ~/.tracks/config/sequencer.toml
```

![image](https://github.com/ruesandora/Airchains/assets/101149671/8be10bf2-c873-4e97-a40d-2dd148854991)

#

> Prepare some preparations for this part and prepare the following command.
> SERVER(VPS) IP `<IP>`
> Get `nodeid>` in the `nano ~/.tracks/config/sequencer.toml` file
> Enter the `AIRCHAIN wallet address` you created before `<WALLET_ADDRESS>`
> Enter the validator name `<moniker-name>`


```console
go run cmd/main.go create-station --accountName <moniker-name> --accountPath $HOME/.tracks/junction-accounts/keys --jsonRPC "https://airchains-testnet-rpc.cosmonautstakes.com/" --info "EVM Track" --tracks <WALLET_ADDRESS> --bootstrapNode "/ip4/<IP>/tcp/2300/p2p/<node_id>"
```

#

> We have set up the station, now let's run it with a service.



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

<h1 align="center">Installation complete, right?</h1>

You have completed the installation process. However, currently, you are not earning points.
We recommend importing the mnemonics of your Tracker wallet into the Leap wallet and connecting to https://points.airchains.io/.
You can view your station and points on the dashboard.
Since we haven't made any transactions yet, you will see 100 points pending. The reason for this is that you need to extract a pod to earn points.
You can think of a pod as a package consisting of 25 transactions. Each set of 25 transactions will generate 1 pod, and you will earn 5 points from these transactions.
The initial 100 points from the installation will become active after the first pod.

For this, we do the following:
Initially, we obtained a private key with the command `bin/bash ./scripts/local-keys.sh` and made RPC settings.
Then we import this private key into Metamask, in the "Add Network" section.

```
rpc http://IP:8545

id 1234

ticker eEVMOS
```

We enter and confirm.

From here on, you can either deploy a contract or manually send transactions; it's up to you.

For those experiencing RPC errors during the tracking process, they can try to roll back. Sometimes the issue is resolved with 1 rollback, other times it may require 3 rollback operations. Run the command `go run cmd/main.go rollback` as many times as you want to perform a rollback. Wait for the output after each run.

```
systemctl stop stationd
cd tracks
git pull
go run cmd/main.go rollback
sudo systemctl restart stationd
sudo journalctl -u stationd -f --no-hostname -o cat
```


<img width="560" alt="Ekran Resmi 2024-06-07 14 18 52" src="https://github.com/ruesandora/Airchains/assets/101149671/8aad779e-85f2-44dd-8c05-0131ea7f089a">


