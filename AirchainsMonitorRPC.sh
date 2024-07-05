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

# URLs of the JSON files
URL1="https://testnet-files.bonynode.online/airchains/.rpc_combined.json"
URL2="https://api.nodejumper.io/api/v1/airchainstestnet/rpcs"

# Global variable to store the last restart time
LAST_RESTART_TIME=$(date +%s)

# Function definitions

cecho() {
    local color="${colors[$1]}"
    local message="$2"
    echo -e "${color}${message}${colors[NC]}"
}

check_and_install_packages() {
    local packages=("figlet" "lolcat" "jq" "curl" "bc")
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


fetch_and_filter_rpcs() {
    # Fetch and combine data from both URLs
    combined_ips=$(
        (curl -s "$URL1" | jq -r 'to_entries[] | select(.value.tx_index == "on") | .key';
         curl -s "$URL2" | jq -r '.[] | select(.tx_index == true) | .ip') | sort | uniq
    )

    # Process combined and deduplicated IPs
    cecho "YELLOW" "Fetching and filtering RPC endpoints..."
    declare -A rpc_response_times
    while read -r ip; do
        # Extract IP and port
        ip_addr=$(echo $ip | cut -d':' -f1)
        port=$(echo $ip | cut -d':' -f2)
        
        # Check if SSL is supported (timeout after 5 seconds)
        if timeout 5 openssl s_client -connect ${ip_addr}:${port} </dev/null &>/dev/null; then
            protocol="https"
        else
            protocol="http"
        fi

        # Check if the site is accessible and measure response time
        start_time=$(date +%s.%N)
        status_code=$(curl -s -o /dev/null -w "%{http_code}" -m 10 ${protocol}://${ip})
        end_time=$(date +%s.%N)
        response_time=$(echo "$end_time - $start_time" | bc)
        
        if [ "$status_code" -ge 200 ] && [ "$status_code" -lt 400 ]; then
            rpc_response_times["${protocol}://${ip}"]=$response_time
        else
            echo
        fi
    done <<< "$combined_ips"

    # Sort RPC endpoints by response time and get the fastest one
    fastest_rpc=$(for rpc in "${!rpc_response_times[@]}"; do
        echo "${rpc_response_times[$rpc]} $rpc"
    done | sort -n | head -n 1 | cut -d' ' -f2-)

    RPC_ENDPOINTS=("$fastest_rpc")
    cecho "GREEN" "Fastest RPC endpoint: ${RPC_ENDPOINTS[0]}"
}

restart_service() {
    cecho "YELLOW" "=> Stopping stationd service..."
    sudo systemctl stop stationd > /dev/null 2>&1
    sudo systemctl restart stationd > /dev/null 2>&1
    sudo systemctl daemon-reload
    sudo systemctl stop rolld

    sleep 10
    sudo systemctl stop stationd > /dev/null 2>&1
    while sudo systemctl is-active --quiet stationd; do
        sleep 5
    done
    
    cecho "YELLOW" "=> Running rollback commands..."
    sleep 10
    if go run cmd/main.go rollback && go run cmd/main.go rollback; then
        cecho "GREEN" "=> Successfully ran rollback commands"
    else
        cecho "RED" "Run this script in the tracks/ folder."
        exit 1
    fi

    sleep 5
    cecho "YELLOW" "=> Removing old logs"
    sudo journalctl --rotate > /dev/null 2>&1
    sudo journalctl --vacuum-time=1s > /dev/null 2>&1
    sudo find /var/log/journal -name "*.journal" | xargs sudo rm -rf
    sudo systemctl restart systemd-journald > /dev/null 2>&1
    sleep 5
    
    cecho "YELLOW" "=> Restarting stationd service..."
    sudo systemctl restart rolld
    sudo systemctl daemon-reload
    sudo systemctl restart stationd > /dev/null 2>&1
    cecho "GREEN" "=> Successfully restarted stationd service"
    
    # Update the last restart time
    LAST_RESTART_TIME=$(date +%s)
}

changeRPC() {
	fetch_and_filter_rpcs
	
    local old_rpc_endpoint=$(grep 'JunctionRPC' ~/.tracks/config/sequencer.toml | cut -d'"' -f2)
    local new_rpc_endpoint="${RPC_ENDPOINTS[0]}"  # Always use the fastest RPC
	
    sed -i "s|JunctionRPC = \".*\"|JunctionRPC = \"$new_rpc_endpoint\"|" ~/.tracks/config/sequencer.toml

    cecho "GREEN" "=> Successfully updated JunctionRPC from $old_rpc_endpoint to: $new_rpc_endpoint"

    restart_service

    clear
    display_banner
}

process_log_line() {
    local line="$1"

    # Check if an hour has passed since the last restart
    local current_time=$(date +%s)
    if (( current_time - LAST_RESTART_TIME >= 3600 )); then
        cecho "YELLOW" "An hour has passed. Restarting service..."
        changeRPC
    fi

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
}

main() {
    clear
    cecho "CYAN" "Starting Airchains Monitor..."

    check_and_install_packages
    
    changeRPC
    
    display_banner

    sudo journalctl -u stationd -f -n 0 --no-hostname -o cat | while read -r line
    do
        process_log_line "$line"
    done
}

main
