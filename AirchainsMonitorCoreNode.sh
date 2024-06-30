#!/bin/bash
clear

check_and_install_packages() {
    local packages=("figlet" "lolcat")
    for package in "${packages[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            sudo apt-get update > /dev/null 2>&1
            sudo apt-get install -y "$package" > /dev/null 2>&1
        fi
    done
}

display_banner() {
    figlet -c "AirchainsMonitor" | lolcat -f
    echo
    echo -e "\e[1;32m📡 Monitoring Airchains Network\e[0m"
    echo -e "\e[1;36m👨‍💻 Created by: @dwtexe\e[0m"
    echo -e "\e[1;33m💰 Donate: air1dksx7yskxthlycnhvkvxs8c452f9eus5cxh6t5\e[0m"
    echo
    echo -e "\e[1;35m🔍 Actively watching for network issues...\e[0m"
    echo
}

echo "Starting Airchains Monitor..."

echo "Stopping tracksd service..."
sudo systemctl stop tracksd

echo "Waiting for tracksd service to stop..."
while sudo systemctl is-active --quiet tracksd; do
    sleep 5
done

echo "tracksd service stopped. Running rollback commands..."
go run cmd/main.go rollback
echo "Successfully ran rollback commands"

echo "Restarting tracksd service..."
sudo systemctl restart tracksd
echo "Successfully restarted tracksd service"

sudo journalctl --rotate > /dev/null 2>&1
sudo journalctl --vacuum-time=1s > /dev/null 2>&1
sudo find /var/log/journal -name "*.journal" | xargs sudo rm
sudo systemctl restart systemd-journald > /dev/null 2>&1
sleep 5

check_and_install_packages


clear
sleep 1
clear
display_banner


RPC_ENDPOINTS=(
    "https://airchains-rpc.sbgid.com/"
    "https://airchains-testnet-rpc.nodesrun.xyz/"
    "https://t-airchains.rpc.utsa.tech/"
    "https://airchains-testnet.rpc.stakevillage.net/"
    "https://airchains-rpc.elessarnodes.xyz/"
    "https://rpc.airchains.aknodes.net"
    "https://rpcair.aznope.com/"
    "https://rpc1.airchains.t.cosmostaking.com/"
    "https://rpc.nodejumper.io/airchainstestnet"
    "https://airchains-testnet-rpc.staketab.org"
    "https://junction-rpc.kzvn.xyz/"
    "https://airchains-rpc-testnet.zulnaaa.com/"
    "https://airchains-testnet-rpc.suntzu.dev/"
    "https://airchains-testnet-rpc.nodesphere.net/"
    "https://junction-rpc.validatorvn.com/"
    "https://rpc-testnet-airchains.nodeist.net/"
    "https://airchains-rpc.kubenode.xyz/"
    "https://airchains-testnet-rpc.cosmonautstakes.com/"
    "https://airchains-testnet-rpc.itrocket.net/"
)


declare -a LAST_5_LINES=()

handle_error() {
    local error_message="$1"
    echo "***********************************************************************"
    echo "===> Error detected: $error_message"
    echo "Taking action to resolve the issue..."

    local old_rpc_endpoint=$(grep 'JunctionRPC' ~/.tracks/config/sequencer.toml | cut -d'"' -f2)

    local current_index=-1
    for i in "${!RPC_ENDPOINTS[@]}"; do
        if [[ "${RPC_ENDPOINTS[$i]}" == "$old_rpc_endpoint" ]]; then
            current_index=$i
            break
        fi
    done

    if [ $current_index -eq -1 ]; then
        new_rpc_endpoint="${RPC_ENDPOINTS[0]}"
    else
        local new_index=$((current_index + 1))
        if [ $new_index -ge ${#RPC_ENDPOINTS[@]} ]; then
            new_index=0
        fi
        new_rpc_endpoint="${RPC_ENDPOINTS[$new_index]}"
    fi

    sed -i "s|JunctionRPC = \".*\"|JunctionRPC = \"$new_rpc_endpoint\"|" ~/.tracks/config/sequencer.toml

    echo "Successfully updated JunctionRPC from $old_rpc_endpoint to: $new_rpc_endpoint"

    echo "Stopping tracksd service..."
    sudo systemctl stop tracksd

    
    echo "Waiting for tracksd service to stop..."
    while sudo systemctl is-active --quiet tracksd; do
        sleep 5
    done

    echo "tracksd service stopped. Running rollback commands..."

    go run cmd/main.go rollback
    echo "Successfully ran rollback commands"

    sudo systemctl restart tracksd
    echo "Successfully restarted tracksd service"

    clear
    
    sudo journalctl --rotate > /dev/null 2>&1
    sudo journalctl --vacuum-time=1s > /dev/null 2>&1
    sudo find /var/log/journal -name "*.journal" | xargs sudo rm
    sudo systemctl restart systemd-journald > /dev/null 2>&1
    sleep 10
    clear
    sudo journalctl --rotate > /dev/null 2>&1
    sudo journalctl --vacuum-time=1s > /dev/null 2>&1
    sudo find /var/log/journal -name "*.journal" | xargs sudo rm
    sudo systemctl restart systemd-journald > /dev/null 2>&1
    sleep 5
    clear

    display_banner
    LAST_5_LINES=()
}

process_log_line() {

    local line="$1"

    if [[ "$line" == tracksd.service:* ]]; then
        return
    fi
    
    echo "$line"

    LAST_5_LINES+=("$line")

    if [ ${#LAST_5_LINES[@]} -gt 5 ]; then
        LAST_5_LINES=("${LAST_5_LINES[@]:1}")
    fi

    if [ $(echo "${LAST_5_LINES[@]}" | grep -o "Failed to get transaction by hash: not found" | wc -l) -ge 2 ]; then
        handle_error "Failed to get transaction by hash: not found (occurred twice in last 5 lines)"
    elif echo "$line" | grep -q -F "Failed to Validate VRF" ||
         echo "$line" | grep -q -F "Failed to Init VRF" ||
         echo "$line" | grep -q -F "Failed to Transact Verify pod" ||
         echo "$line" | grep -q -F "Client connection error: error while requesting node" ||
         echo "$line" | grep -q -F "Switchyard client connection error" ||
         echo "$line" | grep -q -F "error in json rpc client, with http response metadata:" ||
         echo "$line" | grep -q -F "rpc error: code = Unknown desc = rpc error: code = Unknown desc = failed to execute message" ||
         echo "$line" | grep -q -F "error code: '13' msg: 'insufficient fees"; then
        handle_error "$line"
    fi
}

if ! sudo journalctl -u tracksd -f -n 0 --no-hostname -o cat; then
    echo "Failed to read log. Exiting..."
    exit 1
fi | while read -r line
do
    process_log_line "$line"
done
