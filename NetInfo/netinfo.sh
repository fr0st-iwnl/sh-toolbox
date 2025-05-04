#!/bin/bash

# netinfo.sh
#
# A simple script that displays detailed network information, 
# including IP addresses, connection latency, and internet speeds in the terminal.
#
# Author: @fr0st-iwnl
#=================================================================
# Repository: https://github.com/fr0st-iwnl/sh-toolbox
#-----------------------------------------------------------------
# Issue: https://github.com/fr0st-iwnl/sh-toolbox/issues/
# Pull Request: https://github.com/fr0st-iwnl/sh-toolbox/pulls
#-----------------------------------------------------------------

# Colors :)
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Symbols :o
CHECK_MARK="\033[0;32m✓\033[0m"
CROSS_MARK="\033[0;31m✗\033[0m"
ARROW="\033[0;33m➜\033[0m"
INFO_MARK="\033[0;34mℹ\033[0m"
WARNING="\033[0;33m⚠\033[0m"

# Function to display usage
display_usage() {
    echo -e "${BOLD}${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${BLUE}║           NETINFO USAGE                ║${NC}"
    echo -e "${BOLD}${BLUE}╚════════════════════════════════════════╝${NC}"
    echo -e "${ARROW} ${BOLD}Options:${NC}"
    echo -e "  ${CHECK_MARK} ${CYAN}-h, --help${NC}      Show this help message"
    echo -e "  ${CHECK_MARK} ${CYAN}-s, --show-ip${NC}   Show public IP address (hidden by default)"
    echo -e "  ${CHECK_MARK} ${CYAN}-q, --quick${NC}     Show only basic information (no speed test)"
    echo -e "  ${CHECK_MARK} ${CYAN}-n, --no-notify${NC} Disable desktop notification"
}

# Parse arguments
SHOW_IP=false
RUN_SPEEDTEST=true
USE_NOTIFY=true  # Notifications enabled by default

for arg in "$@"; do
    case $arg in
        -h|--help)
            display_usage
            exit 0
            ;;
        -s|--show-ip)
            SHOW_IP=true
            ;;
        -q|--quick)
            RUN_SPEEDTEST=false
            ;;
        -n|--no-notify)
            USE_NOTIFY=false
            ;;
    esac
done

# Print section header
print_header() {
    local text="$1"
    local padding=$(( (40 - ${#text}) / 2 ))
    local padding_str=$(printf '%*s' "$padding" '')
    
    echo -e "\n${BOLD}${PURPLE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${PURPLE}║${padding_str}${text}${padding_str}$([ $(( ${#text} % 2 )) -eq 1 ] && echo " ")║${NC}"
    echo -e "${BOLD}${PURPLE}╚════════════════════════════════════════╝${NC}"
}

# Check for required tools
check_dependency() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${CROSS_MARK} ${RED}Error:${NC} $1 is not installed. Please install it through a package manager to use this feature."
        return 1
    fi
    return 0
}

# Function to output information
output_info() {
    local title="$1"
    local message="$2"
    
    echo -e "${ARROW} ${BOLD}${CYAN}$title:${NC} $message"
}

# Function to show progress notification
show_progress_notification() {
    local title="$1"
    local message="$2"
    
    if [ "$USE_NOTIFY" = true ] && command -v notify-send &> /dev/null; then
        notify-send -t 5000 "$title" "$message" -i network-transmit-receive
    fi
}

# Store results for notification
RESULTS=""
PING_RESULTS=""

# welcome banner :)
echo -e "${BOLD}${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${GREEN}║                 NETINFO                ║${NC}"
echo -e "${BOLD}${GREEN}╚════════════════════════════════════════╝${NC}"

# Get IP address information
print_header "IP ADDRESS INFORMATION"

if [ "$SHOW_IP" = true ]; then
    if check_dependency curl curl; then
        # Try multiple IP services in case one fails
        PUBLIC_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.me || curl -s https://icanhazip.com)
        if [ -n "$PUBLIC_IP" ]; then
            output_info "Public IP Address" "$PUBLIC_IP"
            RESULTS="${RESULTS}📡 <b>Public IP:</b> $PUBLIC_IP\n"
        else
            output_info "Public IP Address" "${RED}Could not retrieve public IP${NC}"
            RESULTS="${RESULTS}📡 <b>Public IP:</b> Could not retrieve\n"
        fi
    fi
else
    output_info "Public IP Address" "${YELLOW}[Hidden for privacy]${NC} Use -s to show"
    RESULTS="${RESULTS}📡 <b>Public IP:</b> [Hidden for privacy]\n"
fi

# Always show local IP
if check_dependency ip iproute2; then
    LOCAL_IP=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n1)
    output_info "Local IP Address" "$LOCAL_IP"
    RESULTS="${RESULTS}🏠 <b>Local IP:</b> $LOCAL_IP\n"
fi

# Network interfaces
print_header "NETWORK INTERFACES"

if check_dependency ip iproute2; then
    INTERFACES=$(ip link | grep -E '^[0-9]+:' | awk -F': ' '{print $2}')
    echo -e "${INFO_MARK} Available interfaces:"
    echo -e "${YELLOW}$(echo "$INTERFACES" | sed 's/^/  → /')${NC}"
    INTERFACES_LIST=$(echo $INTERFACES | tr '\n' ' ')
    RESULTS="${RESULTS}🔌 <b>Interfaces:</b> ${INTERFACES_LIST}\n"
fi

# Speed test using speedtest-cli
if [ "$RUN_SPEEDTEST" = true ]; then
    print_header "SPEED TEST"
    
    # Check if speedtest-cli is installed first
    if ! check_dependency speedtest-cli speedtest-cli; then
        echo
        echo -e "${WARNING} ${YELLOW}Install it with one of these commands:${NC}"
        echo -e "  → sudo apt install speedtest-cli    ${CYAN}(Debian/Ubuntu)${NC}"
        echo -e "  → sudo pacman -S speedtest-cli      ${CYAN}(Arch)${NC}"
        echo -e "  → pip install speedtest-cli         ${CYAN}(Any distro)${NC}"
        echo
        RESULTS="${RESULTS}❌ <b>Speed Test:</b> Not available (speedtest-cli not installed)\n"
    else
        # Initial notification to let the user know the scan has started
        # Only show when speedtest-cli is available and notifications are enabled
        if [ "$USE_NOTIFY" = true ] && command -v notify-send &> /dev/null; then
            notify-send -t 3000 "NetInfo" "Network scan started..." -i network-wireless
        fi
        
        # Variables to store ping results
        GOOGLE_PING=""
        SPEEDTEST_PING=""
        
        # Test ping to Google DNS
        if check_dependency ping iputils-ping; then

            # i dont really like these meh
            # echo -e "${INFO_MARK} ${YELLOW}Testing connection to Google DNS (8.8.8.8)...${NC}"
            # show_progress_notification "NetInfo - Ping Test" "Testing connection to Google DNS..."
            
            GOOGLE_PING=$(ping -c 5 8.8.8.8 | grep -oP 'time=\K[0-9\.]+' | awk '{ sum += $1; n++ } END { if (n > 0) print sum / n " ms"; else print "Error" }')
            PING_RESULTS="${PING_RESULTS}🔄 <b>Google DNS Ping:</b> $GOOGLE_PING\n"
        fi
        
        echo -e "${INFO_MARK} ${YELLOW}Checking latency and internet speeds (this might take a moment)...${NC}"
        
        # Show progress notification for speed test
        show_progress_notification "NetInfo - Speed Test" "Running speed test...\nThis may take a minute."
        
        # Run speedtest-cli with simple output and capture both stdout and stderr
        SPEEDTEST_OUTPUT=$(speedtest-cli --simple 2>&1)
        SPEEDTEST_EXIT_CODE=$?
        
        # Check for "HTTP Error 403" in the output, regardless of exit code
        if echo "$SPEEDTEST_OUTPUT" | grep -q "HTTP Error 403"; then
            echo -e "${WARNING} ${RED}Speedtest servers are blocking your requests!${NC}"
            echo -e "${INFO_MARK} ${YELLOW}You've made too many speed test requests. Please wait a while before trying again.${NC}"
            RESULTS="${RESULTS}⚠️ <b>Speed Test:</b> Temporarily blocked (too many requests)\n"
            
            # Notify user about being blocked
            if [ "$USE_NOTIFY" = true ] && command -v notify-send &> /dev/null; then
                notify-send -t 10000 "NetInfo - Error" "Speedtest servers are blocking your requests!\nPlease wait a while before trying again." -i network-error
            fi
        # Check for "Cannot retrieve speedtest configuration" in the output
        elif echo "$SPEEDTEST_OUTPUT" | grep -q "Cannot retrieve speedtest configuration"; then
            echo -e "${WARNING} ${RED}Cannot connect to Speedtest servers!${NC}"
            echo -e "${INFO_MARK} ${YELLOW}You may be temporarily blocked due to too many requests.${NC}"
            echo -e "${INFO_MARK} ${YELLOW}Please wait a while before trying again.${NC}"
            RESULTS="${RESULTS}⚠️ <b>Speed Test:</b> Server connection blocked\n"
            
            # Notify user about connection issue
            if [ "$USE_NOTIFY" = true ] && command -v notify-send &> /dev/null; then
                notify-send -t 10000 "NetInfo - Error" "Cannot connect to Speedtest servers!\nYou may be temporarily blocked due to too many requests." -i network-error
            fi
        # Check if the command executed successfully
        elif [ $SPEEDTEST_EXIT_CODE -eq 0 ] && echo "$SPEEDTEST_OUTPUT" | grep -q "Download"; then
            # Extract download and upload speeds
            DOWNLOAD=$(echo "$SPEEDTEST_OUTPUT" | grep "Download" | awk '{print $2}')
            UPLOAD=$(echo "$SPEEDTEST_OUTPUT" | grep "Upload" | awk '{print $2}')
            SPEEDTEST_PING=$(echo "$SPEEDTEST_OUTPUT" | grep "Ping" | awk '{print $2}')
            
            # if [ "$USE_NOTIFY" = true ] && command -v notify-send &> /dev/null; then
            #     notify-send -t 5000 "NetInfo - Speed Test Complete" "Download: $DOWNLOAD Mbps\nUpload: $UPLOAD Mbps" -i network-transmit
            # fi
            
            if [ -n "$DOWNLOAD" ]; then
                echo
                echo -e "\n${INFO_MARK} ${YELLOW}Speed Results:${NC}"
                output_info "Download Speed" "${GREEN}$DOWNLOAD Mbps${NC}"
                RESULTS="${RESULTS}⬇️ <b>Download:</b> $DOWNLOAD Mbps\n"
            fi
            
            if [ -n "$UPLOAD" ]; then
                output_info "Upload Speed" "${GREEN}$UPLOAD Mbps${NC}"
                RESULTS="${RESULTS}⬆️ <b>Upload:</b> $UPLOAD Mbps\n"
            fi
            
            # Print ping results together
            echo -e "\n${INFO_MARK} ${YELLOW}Connection Latency:${NC}"
            if [ -n "$GOOGLE_PING" ]; then
                output_info "Google DNS" "$GOOGLE_PING"
            fi
            
            if [ -n "$SPEEDTEST_PING" ] && [ "$SPEEDTEST_PING" != "0.0" ]; then
                output_info "Speedtest Server" "$SPEEDTEST_PING ms"
                echo
                PING_RESULTS="${PING_RESULTS}📶 <b>Speedtest Ping:</b> $SPEEDTEST_PING ms\n"
            fi
        else
            echo -e "${CROSS_MARK} ${RED}Failed to run speed test.${NC}"
            echo -e "${INFO_MARK} ${YELLOW}Error details:${NC}"
            echo -e "  ${RED}$(echo "$SPEEDTEST_OUTPUT" | grep -v "Ping\|Upload\|Download" | head -2)${NC}"
            RESULTS="${RESULTS}❌ <b>Speed Test:</b> Failed\n"
            
            # Notify user about speed test failure
            if [ "$USE_NOTIFY" = true ] && command -v notify-send &> /dev/null; then
                notify-send -t 8000 "NetInfo - Speed Test Failed" "Could not complete the speed test.\nCheck terminal for details." -i dialog-error
            fi
            
            # Show Google DNS ping anyway since we have it
            if [ -n "$GOOGLE_PING" ]; then
                echo -e "\n${INFO_MARK} ${YELLOW}Connection Latency:${NC}"
                output_info "Google DNS" "$GOOGLE_PING"
            fi
        fi
    fi
fi

# Send a single notification at the end with all information
if [ "$USE_NOTIFY" = true ]; then
    if command -v notify-send &> /dev/null; then
        # Get current date and time for the notification
        CURRENT_TIME=$(date "+%H:%M:%S %d/%m/%Y")
        
        # Create a nicely formatted notification with ping results after speeds
        NOTIFICATION_TITLE="NetInfo Summary"
        NOTIFICATION_BODY="<span>🕒 <b>Time:</b> $CURRENT_TIME</span>\n\n${RESULTS}${PING_RESULTS}"
        
        # Send notification with HTML formatting and keep it visible for 15 seconds
        notify-send -t 15000 -i network-wireless "$NOTIFICATION_TITLE" "$NOTIFICATION_BODY"
    else
        echo -e "\n${WARNING} ${YELLOW}notify-send not found. Install libnotify-bin package for notifications.${NC}"
    fi
fi
