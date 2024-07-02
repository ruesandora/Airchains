#!/bin/bash
clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;94m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

cecho() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

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
    clear
    figlet -c "AirchainsMonitor" | lolcat -f
    echo
    cecho "$GREEN" "📡 Monitoring Airchains Network"
    cecho "$CYAN" "👨‍💻 Created by: @dwtexe"
    cecho "$BLUE" "💰 Donate: air1dksx7yskxthlycnhvkvxs8c452f9eus5cxh6t5"
    echo
    cecho "$MAGENTA" "🔍 Actively watching for network issues..."
    echo
}

RPC_ENDPOINTS=(
    "https://airchains-rpc.sbgid.com/"
    "https://airchains-rpc.tws.im/"
    "https://junction-testnet-rpc.synergynodes.com/" 
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

wait_for_database_init() {
    cecho "$YELLOW" "Waiting for database initialization..."
	echo
    while IFS= read -r line; do
        if [[ "$line" == *"Database Initialized"* ]]; then
            echo "$line"
            cecho "$GREEN" "Database initialized. Starting log monitoring..."
            break
        fi
    done < <(sudo journalctl -u stationd -f -n 0 --no-hostname -o cat)
}

handle_error() {
    cecho "$RED" "***********************************************************************"
	echo
    cecho "$RED" "===> Error Detected <==="
    cecho "$YELLOW" "=> Taking action to resolve the issue..."
	sleep 0.2
	cecho "$CYAN" "*"
	sleep 0.2
	cecho "$BLUE" "*"
	sleep 0.2
	cecho "$MAGENTA" "*"

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

    cecho "$GREEN" "=> Successfully updated JunctionRPC from $old_rpc_endpoint to: $new_rpc_endpoint"

    cecho "$YELLOW" "=> Stopping stationd service..."
	cecho "$YELLOW" "=> Waiting for stationd service to stop..."
    sudo systemctl stop stationd > /dev/null 2>&1

    cecho "$YELLOW" "=> Stationd service stopped. Running rollback commands..."

	if ! go run cmd/main.go rollback; then
		cecho  "$RED" "Failed to rollback. Exiting..."
		cecho  "$RED" "Run this script on the tracks/ folder."
		exit 1
	if ! go run cmd/main.go rollback; then
		cecho  "$RED" "Failed to rollback. Exiting..."
		cecho  "$RED" "Run this script on the tracks/ folder."
		exit 1
    cecho "$GREEN" "=> Successfully ran rollback commands"
	cecho "$YELLOW" "Restarting stationd service..."
	sudo systemctl restart stationd > /dev/null 2>&1
	cecho "$GREEN" "Successfully restarted stationd service"

    cecho "$CYAN" "=> Removing old logs"
    sudo journalctl --rotate > /dev/null 2>&1
    sudo journalctl --vacuum-time=1s > /dev/null 2>&1
    sudo find /var/log/journal -name "*.journal" | xargs sudo rm
    sudo systemctl restart systemd-journald > /dev/null 2>&1

    cecho "$YELLOW" "=> Restarting stationd service..."
    sudo systemctl restart stationd > /dev/null 2>&1
    cecho "$GREEN" "=> Successfully restarted stationd service"

    clear

    display_banner
    LAST_5_LINES=()

    wait_for_database_init
}

process_log_line() {
    local line="$1"

    # Filter out unwanted lines
    if [[ "$line" == *stationd.service:* ]] || 
       [[ "$line" == *DBG* ]] || 
       [[ "$line" == *"compiling circuit"* ]] ||
       [[ "$line" == *"parsed circuit inputs"* ]] ||
       [[ "$line" == *"building constraint builder"* ]] ||
       [[ "$line" == *"VRF Initiated Successfully"* ]] ||
       [[ "$line" == *"Eigen DA Blob KEY:"* ]] ||
       [[ "$line" == *"Pod submitted successfully"* ]] ||
       [[ "$line" == *"VRF Validated Tx Success"* ]] ||
       [[ "$line" == *"Generating proof"* ]] ||
       [[ "$line" == *"Pod Verification Tx Success"* ]]; then
        return
    elif [[ "$line" == *"Generating New unverified pods"* ]]; then
        echo
        cecho "$BLUE" "=***=***=***=***=***=***=***="
        echo
    fi

    # Simplify error messages
    if [[ "$line" == *"Error="* && "$line" == *"account sequence mismatch"* ]]; then
        local timestamp=$(echo "$line" | awk '{print $1}')
        local error_type=$(echo "$line" | sed -n 's/.*ERR Error in \(.*\) Error=.*/\1/p')
        local expected=$(echo "$line" | sed -n 's/.*expected \([0-9]*\).*/\1/p')
        local got=$(echo "$line" | sed -n 's/.*got \([0-9]*\).*/\1/p')
        echo "${timestamp} Error in ${error_type} Error=\"account sequence mismatch, expected ${expected}, got ${got}: incorrect account sequence\""
	elif [[ "$line" == *"Error in InitVRF transaction Error="* && "$line" == *"waiting for next block: error while requesting node"* ]]; then
		local timestamp=$(echo "$line" | awk '{print $1}')
		local url=$(echo "$line" | sed -n "s/.*requesting node '\([^']*\)'.*/\1/p")
		echo "${timestamp} Error in InitVRF transaction Error=\"waiting for next block: error while requesting node '${url}'\""
	elif [[ "$line" == *"Error in"* && "$line" == *"insufficient fees"* ]]; then
        local timestamp=$(echo "$line" | awk '{print $1}')
        local error_type=$(echo "$line" | sed -n 's/.*ERR Error in \(.*\) Error=.*/\1/p')
        local fees=$(echo "$line" | sed -n 's/.*insufficient fees; got: \([^;]*\) required: \([^:]*\).*/got: \1 required: \2/p')
        echo "${timestamp} Error in ${error_type} Error=\"insufficient fees; ${fees}:\""
	elif [[ "$line" == *"ERR Error in SubmitPod Transaction Error="* && "$line" == *"rpc error:"* && "$line" == *"failed to execute message"* ]]; then
        local timestamp=$(echo "$line" | awk '{print $1}')
        echo "${timestamp} Error in SubmitPod Transaction Error=\"rpc error: failed to execute message; invalid request\""
    else
        echo "$line"
    fi

    # Rest of your error handling logic...
    LAST_5_LINES+=("$line")
    if [ ${#LAST_5_LINES[@]} -gt 5 ]; then
        LAST_5_LINES=("${LAST_5_LINES[@]:1}")
    fi

    # Check for repeated errors in the last 5 lines
    local insufficient_fees_count=$(printf '%s\n' "${LAST_5_LINES[@]}" | grep -c "error code: '13' msg: 'insufficient fees")
    local message_index_count=$(printf '%s\n' "${LAST_5_LINES[@]}" | grep -c "message index: 0")

    if [ $(printf '%s\n' "${LAST_5_LINES[@]}" | grep -c "Failed to get transaction by hash: not found") -ge 2 ]; then
        handle_error 
    elif [ $insufficient_fees_count -ge 2 ]; then
        handle_error 
    elif [ $message_index_count -ge 2 ]; then
        handle_error
    elif echo "$line" | grep -q -F "Failed to Validate VRF" ||
         echo "$line" | grep -q -F "Failed to Init VRF" ||
         echo "$line" | grep -q -F "Failed to Transact Verify pod" ||
         echo "$line" | grep -q -F "Client connection error: error while requesting node" ||
         echo "$line" | grep -q -F "Switchyard client connection error" ||
         echo "$line" | grep -q -F "error in json rpc client, with http response metadata:"; then
        handle_error "$line"
    fi
}

cecho "$CYAN" "Starting Airchains Monitor..."

check_and_install_packages

cecho "$YELLOW" "Stopping stationd service..."
cecho "$YELLOW" "Waiting for stationd service to stop..."
sudo systemctl stop stationd > /dev/null 2>&1


cecho "$YELLOW" "Stationd service stopped. Running rollback commands..."
if ! go run cmd/main.go rollback; then
	cecho  "$RED" "Failed to rollback. Exiting..."
	cecho  "$RED" "Run this script on the tracks/ folder."
	exit 1
cecho "$GREEN" "Successfully ran rollback commands"

cecho "$YELLOW" "Restarting stationd service..."
sudo systemctl restart stationd > /dev/null 2>&1
cecho "$GREEN" "Successfully restarted stationd service"

cecho "$CYAN" "Removing old logs"
sudo journalctl --rotate > /dev/null 2>&1
sudo journalctl --vacuum-time=1s > /dev/null 2>&1
sudo find /var/log/journal -name "*.journal" | xargs sudo rm
sudo systemctl restart systemd-journald > /dev/null 2>&1

cecho "$YELLOW" "Restarting stationd service..."
sudo systemctl restart stationd > /dev/null 2>&1
cecho "$GREEN" "Successfully restarted stationd service"

display_banner

wait_for_database_init

if ! sudo journalctl -u stationd -f -n 0 --no-hostname -o cat; then
    cecho "$RED" "Failed to read log. Exiting..."
    exit 1
fi | while read -r line
do
    process_log_line "$line"
done
