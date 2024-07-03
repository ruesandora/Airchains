#!/bin/bash

# Color definitions
declare -A colors=(
    ["RED"]='\033[0;31m'
    ["GREEN"]='\033[0;32m'
    ["YELLOW"]='\033[1;33m'
    ["BLUE"]='\033[0;94m'
    ["MAGENTA"]='\033[0;35m'
    ["CYAN"]='\033[0;36m'
    ["WHITE"]='\033[1;37m'
    ["NC"]='\033[0m' # No Color
)

# Configuration
RPC_ENDPOINTS=(
    "https://airchains-rpc.sbgid.com/"
    "https://junction-testnet-rpc.nodesync.top/"
    "https://airchains.rpc.t.stavr.tech/"
    "https://airchains-testnet-rpc.corenode.info/"
    "https://airchains-testnet-rpc.spacestake.tech/"
    "https://airchains-rpc.chainad.org/"
    "https://rpc.airchains.stakeup.tech/"
    "https://airchains-testnet-rpc.spacestake.tech/"
    "https://airchains-testnet-rpc.stakerhouse.com/"
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
    "https://airchains-testnet-rpc.zulnaaa.com/"
    "https://airchains-testnet-rpc.suntzu.dev/"
    "https://airchains-testnet-rpc.nodesphere.net/"
    "https://junction-rpc.validatorvn.com/"
    "https://rpc-testnet-airchains.nodeist.net/"
    "https://airchains-rpc.kubenode.xyz/"
    "https://airchains-testnet-rpc.cosmonautstakes.com/"
    "https://airchains-testnet-rpc.itrocket.net/"
)

LAST_5_LINES=()
LAST_20_LINES=()
MAX_RETRIES=3
RETRY_DELAY=5

# Function definitions

cecho() {
    local color="${colors[$1]}"
    local message="$2"
    echo -e "${color}${message}${colors[NC]}"
}

check_and_install_packages() {
    local packages=("figlet" "lolcat")
    for package in "${packages[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            cecho "YELLOW" "Installing $package..."
            sudo apt-get update > /dev/null 2>&1
            sudo apt-get install -y "$package" > /dev/null 2>&1
            cecho "GREEN" "$package installed successfully."
        fi
    done
}

display_banner() {
    clear
    figlet -c "AirchainsMonitor" | lolcat -f
    echo
    cecho "GREEN" "📡 Monitoring Airchains Network"
    cecho "CYAN" "👨‍💻 Created by: @dwtexe"
    cecho "BLUE" "💰 Donate: air1dksx7yskxthlycnhvkvxs8c452f9eus5cxh6t5"
    echo
    cecho "MAGENTA" "🔍 Actively watching for network issues..."
    echo
}

wait_for_database_init() {
    cecho "YELLOW" "Waiting for database initialization and RPC server start..."
    echo
    while IFS= read -r line; do
        case "$line" in
            *"Database Initialized"*)
                echo "$line"
                ;;
            *"RPC Server Stared"*)
                echo "$line"
                echo
                cecho "GREEN" "Database initialized and RPC server started. Starting log monitoring..."
                echo
                return
                ;;
        esac
    done < <(sudo journalctl -u stationd -f -n 0 --no-hostname -o cat)
}

handle_error() {
    cecho "RED" "***********************************************************************"
    echo
    cecho "RED" "===> Error Detected <==="
    cecho "YELLOW" "=> Taking action to resolve the issue..."
	
    local old_rpc_endpoint=$(grep 'JunctionRPC' ~/.tracks/config/sequencer.toml | cut -d'"' -f2)
    local new_rpc_endpoint

    # Find the index of the current RPC endpoint and select the next one
    for i in "${!RPC_ENDPOINTS[@]}"; do
        if [[ "${RPC_ENDPOINTS[$i]}" == "$old_rpc_endpoint" ]]; then
            new_rpc_endpoint="${RPC_ENDPOINTS[$(( (i + 1) % ${#RPC_ENDPOINTS[@]} ))]}"
            break
        fi
    done

    # If the current endpoint wasn't found, use the first one
    if [[ -z "$new_rpc_endpoint" ]]; then
        new_rpc_endpoint="${RPC_ENDPOINTS[0]}"
    fi

    sed -i "s|JunctionRPC = \".*\"|JunctionRPC = \"$new_rpc_endpoint\"|" ~/.tracks/config/sequencer.toml

    cecho "GREEN" "=> Successfully updated JunctionRPC from $old_rpc_endpoint to: $new_rpc_endpoint"

    restart_service

    clear
    display_banner
    LAST_5_LINES=()
    LAST_20_LINES=()

    wait_for_database_init
}

restart_service() {
    cecho "YELLOW" "=> Stopping stationd service..."
	systemctl stop stationd && go run cmd/main.go rollback && sudo systemctl restart stationd
	sleep 20
    sudo systemctl stop stationd > /dev/null 2>&1
    cecho "YELLOW" "=> Running rollback commands..."
	sleep 20
    local retry_count=0
    while [ $retry_count -lt $MAX_RETRIES ]; do
        if go run cmd/main.go rollback; then
            cecho "GREEN" "=> Successfully ran rollback commands"
            break
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $MAX_RETRIES ]; then
                cecho "YELLOW" "Rollback failed. Retrying in $RETRY_DELAY seconds..."
                sleep $RETRY_DELAY
            else
                cecho "RED" "Failed to rollback after $MAX_RETRIES attempts. Exiting..."
                cecho "RED" "Run this script in the tracks/ folder."
                exit 1
            fi
        fi
    done
	sleep 10
    cecho "YELLOW" "=> Removing old logs"
    sudo journalctl --rotate > /dev/null 2>&1
    sudo journalctl --vacuum-time=1s > /dev/null 2>&1
    sudo find /var/log/journal -name "*.journal" | xargs sudo rm
    sudo systemctl restart systemd-journald > /dev/null 2>&1
	sleep 10
    cecho "YELLOW" "=> Restarting stationd service..."
    sudo systemctl restart stationd > /dev/null 2>&1
    cecho "GREEN" "=> Successfully restarted stationd service"
}

process_log_line() {
    local line="$1"

    # Filter out unwanted lines
    if [[ "$line" =~ stationd\.service:|DBG|"compiling circuit"|"parsed circuit inputs"|"building constraint builder"|"VRF Initiated Successfully"|"Eigen DA Blob KEY:"|"Pod submitted successfully"|"VRF Validated Tx Success"|"Generating proof"|"Pod Verification Tx Success" ]]; then
        return
    elif [[ "$line" == *"Generating New unverified pods"* ]]; then
        echo
        cecho "BLUE" "=***=***=***=***=***=***=***="
        echo
    fi

    # Simplify error messages
    case "$line" in
        *"Error="*"account sequence mismatch"*)
            local timestamp=$(echo "$line" | awk '{print $1}')
            local error_type=$(echo "$line" | sed -n 's/.*ERR Error in \(.*\) Error=.*/\1/p')
            local expected=$(echo "$line" | sed -n 's/.*expected \([0-9]*\).*/\1/p')
            local got=$(echo "$line" | sed -n 's/.*got \([0-9]*\).*/\1/p')
            echo "${timestamp} Error in ${error_type} Error=\"account sequence mismatch, expected ${expected}, got ${got}: incorrect account sequence\""
            ;;
        *"Error in InitVRF transaction Error="*"waiting for next block: error while requesting node"*)
            local timestamp=$(echo "$line" | awk '{print $1}')
            local url=$(echo "$line" | sed -n "s/.*requesting node '\([^']*\)'.*/\1/p")
            echo "${timestamp} Error in InitVRF transaction Error=\"waiting for next block: error while requesting node '${url}'\""
            ;;
        *"Error in"*"insufficient fees"*)
            local timestamp=$(echo "$line" | awk '{print $1}')
            local error_type=$(echo "$line" | sed -n 's/.*ERR Error in \(.*\) Error=.*/\1/p')
            local fees=$(echo "$line" | sed -n 's/.*insufficient fees; got: \([^;]*\) required: \([^:]*\).*/got: \1 required: \2/p')
            echo "${timestamp} Error in ${error_type} Error=\"insufficient fees; ${fees}:\""
            ;;
        *"failed to execute message"*)
            local timestamp=$(echo "$line" | awk '{print $1}')
            echo "${timestamp} Error in SubmitPod Transaction Error=\"rpc error: failed to execute message; invalid request\""
            ;;
        *"Error in SubmitPod Transaction"*"error in json rpc client"*)
            local timestamp=$(echo "$line" | awk '{print $1}')
            echo "${timestamp} Error in SubmitPod Transaction Error=\"error in json rpc client\""
            ;;
        *"Error in VerifyPod transaction"*"error in json rpc client"*)
            local timestamp=$(echo "$line" | awk '{print $1}')
            echo "${timestamp} Error in VerifyPod transaction Error=\"error in json rpc client\""
            ;;
        *"request ratelimited"*)
            local timestamp=$(echo "$line" | awk '{print $1}')
            echo "${timestamp} Error Request rate limited"
            ;;
        *"Error in ValidateVRF transaction"*)
            local timestamp=$(echo "$line" | awk '{print $1}')
            echo "${timestamp} Error in ValidateVRF transaction Error=\"error in json rpc client\""
            ;;
        *)
            echo "$line"
            ;;
    esac

    LAST_5_LINES+=("$line")
    if [ ${#LAST_5_LINES[@]} -gt 5 ]; then
        LAST_5_LINES=("${LAST_5_LINES[@]:1}")
    fi
    LAST_20_LINES+=("$line")
    if [ ${#LAST_20_LINES[@]} -gt 20 ]; then
        LAST_20_LINES=("${LAST_20_LINES[@]:1}")
    fi

    # Check for repeated errors in the last 5 lines
    local insufficient_fees_count=$(printf '%s\n' "${LAST_20_LINES[@]}" | grep -c "error code: '13' msg: 'insufficient fees")
    local message_index_count=$(printf '%s\n' "${LAST_20_LINES[@]}" | grep -c "message index: 0")
    local rpc_client_count=$(printf '%s\n' "${LAST_20_LINES[@]}" | grep -c "error in json rpc client")

    if [ $(printf '%s\n' "${LAST_5_LINES[@]}" | grep -c "Failed to get transaction by hash: not found") -ge 2 ] ||
       [ $message_index_count -ge 5 ] ||
       [ $insufficient_fees_count -ge 10 ] ||
	   [ $rpc_client_count -ge 10 ] ||
       [[ "$line" =~ "Failed to Validate VRF"|"Failed to Init VRF"|"Failed to Transact Verify pod"|"Client connection error: error while requesting node"|"Switchyard client connection error" ]]; then
        handle_error
    fi
}

main() {
	clear
    cecho "CYAN" "Starting Airchains Monitor..."

    check_and_install_packages

    restart_service

    display_banner

    wait_for_database_init

    sudo journalctl -u stationd -f -n 0 --no-hostname -o cat | while read -r line
    do
        process_log_line "$line"
    done
}

main
