# Airchains

sudo apt update -y && sudo apt upgrade -y
sudo apt install -y curl git jq lz4 build-essential cmake perl tmux automake autoconf libtool wget libssl-dev

git clone https://github.com/airchains-network/evm-station.git
git clone https://github.com/airchains-network/tracks.git

# ben celestia olarak anlatıcam
git clone https://github.com/celestiaorg/celestia-node.git

cd evm-station
go mod tidy
