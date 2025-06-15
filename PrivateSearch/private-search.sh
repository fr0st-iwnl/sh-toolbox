#!/bin/bash

# private-search.sh
#
# Script to install and configure a private search engine
#
# Author: @fr0st-iwnl
#=================================================================
# Repository: https://github.com/fr0st-iwnl/sh-toolbox
#-----------------------------------------------------------------
# Issues: https://github.com/fr0st-iwnl/sh-toolbox/issues/
# Pull Requests: https://github.com/fr0st-iwnl/sh-toolbox/pulls
#-----------------------------------------------------------------

# Colors :)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print the main script header (only used once at the beginning)
print_header() {
   echo -e "${BOLD}${BLUE}"
   echo "┌───────────────────────────────────┐"
   echo "│          PRIVATE-SEARCH           │"
   echo "└───────────────────────────────────┘"
   echo -e "${NC}"
}

# Function to print a section header
print_section() {
    echo
    echo -e "${CYAN}${BOLD}▶ $1${NC}"
    echo -e "${CYAN}${BOLD}───────────────────────────${NC}"
}

# Function to print a section header
print_section_engine() {
    echo
    echo -e "${CYAN}${BOLD}▶ $1${NC}"
    echo -e "${CYAN}${BOLD}───────────────────────────────────────${NC}"
}

# Function to print success message
print_success() {
    echo -e "${GREEN}$1${NC}"
}

# Function to print error message
print_error() {
    echo -e "${RED}$1${NC}"
}

# Function to print info message
print_info() {
    echo -e "${YELLOW}$1${NC}"
}

# Function to display help message
display_help() {
    print_header
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  ${GREEN}sudo private-search${NC} - Install and configure a private search engine"
    echo -e "  ${GREEN}sudo private-search -r${NC} - Remove installed search engine completely"
    echo -e "  ${GREEN}sudo private-search -h${NC} - Display this help message"
    echo ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  ${GREEN}-h${NC}  Display this help message"
    echo -e "  ${GREEN}-r${NC}  Remove installed search engine container, image, and configuration"
    echo
    exit 0
}

# Display menu and get user choice
show_search_menu() {
    print_header
    print_section_engine "Choose a Search Engine to Setup"
    
    echo -e "1) ${CYAN}SearXNG${NC} - Privacy-respecting metasearch engine"
    echo -e "2) ${CYAN}Whoogle${NC} - Self-hosted, ad-free, privacy-respecting Google search"
    echo
    echo -e "${BOLD}${BLUE}╭─ Enter your choice (1-2):${NC}"
    echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
    read -r SEARCH_ENGINE_CHOICE
    
    case $SEARCH_ENGINE_CHOICE in
        1)
            SEARCH_ENGINE="searxng"
            ;;
        2)
            SEARCH_ENGINE="whoogle"
            ;;
        *)
            echo
            print_error "Invalid choice. Please select 1 for SearXNG or 2 for Whoogle."
            echo
            exit 1
            ;;
    esac
}

# Function to remove installed search engine
remove_search_engine() {
    print_header
    
    # Check if Whoogle is installed
    if docker ps -a | grep -q "whoogle-search"; then
        print_section "Removing Whoogle Container and Image"
        
        print_info "Stopping container..."
        docker stop whoogle-search 2>/dev/null || print_info "No running container found"
        
        print_info "Removing container..."
        docker rm whoogle-search 2>/dev/null || print_info "No container found"
        
        print_info "Removing image..."
        docker rmi benbusby/whoogle-search 2>/dev/null || print_info "No image found"
        
        # Remove systemd service if it exists
        if [ -f "/etc/systemd/system/whoogle.service" ]; then
            print_info "Removing systemd service..."
            systemctl stop whoogle.service 2>/dev/null
            systemctl disable whoogle.service 2>/dev/null
            rm -f /etc/systemd/system/whoogle.service
            systemctl daemon-reload
        fi
    fi
    
    # Check if SearXNG is installed
    if docker ps -a | grep -q "searxng-search"; then
        print_section "Removing SearXNG Container and Image"
        
        print_info "Stopping container..."
        docker stop searxng-search 2>/dev/null || print_info "No running container found"
        
        print_info "Removing container..."
        docker rm searxng-search 2>/dev/null || print_info "No container found"
        
        print_info "Removing image..."
        docker rmi searxng/searxng 2>/dev/null || print_info "No image found"
        
        # Remove systemd service if it exists
        if [ -f "/etc/systemd/system/searxng.service" ]; then
            print_info "Removing systemd service..."
            systemctl stop searxng.service 2>/dev/null
            systemctl disable searxng.service 2>/dev/null
            rm -f /etc/systemd/system/searxng.service
            systemctl daemon-reload
        fi
    fi
    
    # Remove config file
    if [ -f "$CONFIG_FILE" ]; then
        print_info "Removing configuration file..."
        rm -f "$CONFIG_FILE"
    fi
    
    print_success "Search engine has been removed."
    exit 0
}

# Setup and run SearXNG
setup_searxng() {
    # Default port only - no default IP
    DEFAULT_PORT="8080"
    CONFIG_FILE="/etc/private-search/config"

    # Create config directory if it doesn't exist
    mkdir -p /etc/private-search

    print_section "Configuration Setup"

    # Check for existing config and if default IP has been changed
    if [ -f "$CONFIG_FILE" ]; then
        STORED_ENGINE=$(grep -oP "^ENGINE=\K.*" "$CONFIG_FILE" 2>/dev/null || echo "")
        
        # If the stored engine is different, start fresh
        if [ "$STORED_ENGINE" != "searxng" ]; then
            # Different engine was installed before, reset config
            rm -f "$CONFIG_FILE"
        else
            STORED_IP=$(grep -oP "^IP=\K.*" "$CONFIG_FILE")
            STORED_PORT=$(grep -oP "^PORT=\K.*" "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_PORT")
            
            # Display previous IP configuration with better handling for empty IP
            if [ -z "$STORED_IP" ]; then
                print_info "Previous configuration: All interfaces (0.0.0.0)"
            else
                print_info "Previous IP: $STORED_IP"
            fi
            
            echo
            echo -e "${BOLD}${BLUE}╭─ Enter the local IP address where SearXNG should be accessible${NC}"
            echo -e "${BOLD}${BLUE}│${NC}  (leave empty for all interfaces, like localhost"
            echo -e "${BOLD}${BLUE}│${NC}   or enter your server's local/private IP address):"
            echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
            read -r USER_IP
            
            if [ -z "$USER_IP" ]; then
                LOCAL_IP=""
                print_info "Will bind to all network interfaces (0.0.0.0)"
            else
                LOCAL_IP="$USER_IP"
            fi
            
            IP_CHANGED=true
            
            # If port is different from default, ask for confirmation
            if [ "$STORED_PORT" != "$DEFAULT_PORT" ]; then
                print_info "Previous port: $STORED_PORT"
                print_info "Default port: $DEFAULT_PORT"
                echo
                echo -e "${BOLD}${BLUE}╭─ Enter the port where SearXNG should be accessible${NC}"
                echo -e "${BOLD}${BLUE}│${NC}  (press ${GREEN}Enter${NC} to use previous port: ${CYAN}$STORED_PORT${NC}):"
                echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
                read -r USER_PORT
                
                if [ -z "$USER_PORT" ]; then
                    LOCAL_PORT="$STORED_PORT"
                else
                    LOCAL_PORT="$USER_PORT"
                fi
                
                PORT_CHANGED=true
            else
                # Use the stored PORT
                LOCAL_PORT="$STORED_PORT"
                PORT_CHANGED=false
            fi
            
            # Update config
            echo "ENGINE=searxng" > "$CONFIG_FILE"
            echo "IP=$LOCAL_IP" >> "$CONFIG_FILE"
            echo "PORT=$LOCAL_PORT" >> "$CONFIG_FILE"
            
            print_info "Using IP: ${LOCAL_IP:-"All interfaces (0.0.0.0)"}"
            print_info "Using port: $LOCAL_PORT"
        fi
    fi

    # If config file doesn't exist or was reset, create a new one
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${BOLD}${BLUE}╭─ Enter the local IP address where SearXNG should be accessible${NC}"
        echo -e "${BOLD}${BLUE}│${NC}  (leave empty for all interfaces, like localhost"
        echo -e "${BOLD}${BLUE}│${NC}   or enter your server's local/private IP address):"
        echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
        read -r USER_IP
        
        if [ -z "$USER_IP" ]; then
            LOCAL_IP=""
            print_info "Will bind to all network interfaces (0.0.0.0)"
        else
            LOCAL_IP="$USER_IP"
        fi
        
        # Ask user for port
        echo
        echo -e "${BOLD}${BLUE}╭─ Enter the port where SearXNG should be accessible${NC}"
        echo -e "${BOLD}${BLUE}│${NC}  (press ${GREEN}Enter${NC} to use default port: ${CYAN}$DEFAULT_PORT${NC}):"
        echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
        read -r USER_PORT
        
        if [ -z "$USER_PORT" ]; then
            LOCAL_PORT="$DEFAULT_PORT"
        else
            LOCAL_PORT="$USER_PORT"
        fi
        
        # Save config for future runs
        echo "ENGINE=searxng" > "$CONFIG_FILE"
        echo "IP=$LOCAL_IP" >> "$CONFIG_FILE"
        echo "PORT=$LOCAL_PORT" >> "$CONFIG_FILE"
        
        print_info "Using IP: ${LOCAL_IP:-"All interfaces (0.0.0.0)"}"
        print_info "Using port: $LOCAL_PORT"
    fi

    # Pull the SearXNG Docker image
    print_section "Pulling Docker Image"
    print_info "Pulling SearXNG Docker image..."
    docker pull searxng/searxng

    # If IP is empty, set binding to all interfaces
    BINDING_IP=${LOCAL_IP:-"0.0.0.0"}

    # Run SearXNG on the specified local IP and port
    print_section "Starting SearXNG Container"
    print_info "Running SearXNG container on $BINDING_IP:$LOCAL_PORT..."
    docker run -d \
        -p "$BINDING_IP:$LOCAL_PORT:8080" \
        --name searxng-search \
        --restart unless-stopped \
        -e SEARXNG_BASE_URL="http://${BINDING_IP}:${LOCAL_PORT}/" \
        searxng/searxng

    # Create systemd service for auto-starting at boot
    print_section "Setting Up Systemd Service"
    print_info "Creating systemd service for SearXNG..."

    # Create the service file content
    cat > /etc/systemd/system/searxng.service << EOF
[Unit]
Description=SearXNG Search Engine Container
After=docker.service network-online.target
Wants=network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/usr/bin/docker pull searxng/searxng
ExecStart=/bin/sh -c '/usr/bin/docker start searxng-search || /usr/bin/docker run -d -p "$BINDING_IP:$LOCAL_PORT:8080" --name searxng-search --restart unless-stopped -e SEARXNG_BASE_URL="http://${BINDING_IP}:${LOCAL_PORT}/" searxng/searxng'
ExecStop=/usr/bin/docker stop searxng-search

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd daemon
    systemctl daemon-reload

    # Enable and start the service
    systemctl enable searxng.service
    systemctl start searxng.service

    # Determine the display URL
    if [ -z "$LOCAL_IP" ]; then
        DISPLAY_IP="localhost"
    else
        DISPLAY_IP="$LOCAL_IP"
    fi

    # Confirmation message
    print_section "Setup Complete"
    print_success "SearXNG setup completed"
    print_success "You can access SearXNG at: http://$DISPLAY_IP:$LOCAL_PORT"
    print_success "A systemd service has been installed to ensure SearXNG starts at boot."
    print_info "You can check its status with: systemctl status searxng.service"
}

# Setup and run Whoogle
setup_whoogle() {
    # Default port only - no default IP
    DEFAULT_PORT="8080"
    CONFIG_FILE="/etc/private-search/config"

    # Create config directory if it doesn't exist
    mkdir -p /etc/private-search

    print_section "Configuration Setup"

    # Check for existing config and if default IP has been changed
    if [ -f "$CONFIG_FILE" ]; then
        STORED_ENGINE=$(grep -oP "^ENGINE=\K.*" "$CONFIG_FILE" 2>/dev/null || echo "")
        
        # If the stored engine is different, start fresh
        if [ "$STORED_ENGINE" != "whoogle" ]; then
            # Different engine was installed before, reset config
            rm -f "$CONFIG_FILE"
        else
            STORED_IP=$(grep -oP "^IP=\K.*" "$CONFIG_FILE")
            STORED_PORT=$(grep -oP "^PORT=\K.*" "$CONFIG_FILE" 2>/dev/null || echo "$DEFAULT_PORT")
            
            # Display previous IP configuration with better handling for empty IP
            if [ -z "$STORED_IP" ]; then
                print_info "Previous configuration: All interfaces (0.0.0.0)"
            else
                print_info "Previous IP: $STORED_IP"
            fi
            
            echo
            echo -e "${BOLD}${BLUE}╭─ Enter the local IP address where Whoogle should be accessible${NC}"
            echo -e "${BOLD}${BLUE}│${NC}  (leave empty for all interfaces, like localhost"
            echo -e "${BOLD}${BLUE}│${NC}   or enter your server's local/private IP address):"
            echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
            read -r USER_IP
            
            if [ -z "$USER_IP" ]; then
                LOCAL_IP=""
                print_info "Will bind to all network interfaces (0.0.0.0)"
            else
                LOCAL_IP="$USER_IP"
            fi
            
            IP_CHANGED=true
            
            # If port is different from default, ask for confirmation
            if [ "$STORED_PORT" != "$DEFAULT_PORT" ]; then
                print_info "Previous port: $STORED_PORT"
                print_info "Default port: $DEFAULT_PORT"
                echo
                echo -e "${BOLD}${BLUE}╭─ Enter the port where Whoogle should be accessible${NC}"
                echo -e "${BOLD}${BLUE}│${NC}  (press ${GREEN}Enter${NC} to use previous port: ${CYAN}$STORED_PORT${NC}):"
                echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
                read -r USER_PORT
                
                if [ -z "$USER_PORT" ]; then
                    LOCAL_PORT="$STORED_PORT"
                else
                    LOCAL_PORT="$USER_PORT"
                fi
                
                PORT_CHANGED=true
            else
                # Use the stored PORT
                LOCAL_PORT="$STORED_PORT"
                PORT_CHANGED=false
            fi
            
            # Update config
            echo "ENGINE=whoogle" > "$CONFIG_FILE"
            echo "IP=$LOCAL_IP" >> "$CONFIG_FILE"
            echo "PORT=$LOCAL_PORT" >> "$CONFIG_FILE"
            
            print_info "Using IP: ${LOCAL_IP:-"All interfaces (0.0.0.0)"}"
            print_info "Using port: $LOCAL_PORT"
        fi
    fi
    
    # If config file doesn't exist or was reset, create a new one
    if [ ! -f "$CONFIG_FILE" ]; then
        echo -e "${BOLD}${BLUE}╭─ Enter the local IP address where Whoogle should be accessible${NC}"
        echo -e "${BOLD}${BLUE}│${NC}  (leave empty for all interfaces, like localhost"
        echo -e "${BOLD}${BLUE}│${NC}   or enter your server's local/private IP address):"
        echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
        read -r USER_IP
        
        if [ -z "$USER_IP" ]; then
            LOCAL_IP=""
            print_info "Will bind to all network interfaces (0.0.0.0)"
        else
            LOCAL_IP="$USER_IP"
        fi
        
        # Ask user for port
        echo
        echo -e "${BOLD}${BLUE}╭─ Enter the port where Whoogle should be accessible${NC}"
        echo -e "${BOLD}${BLUE}│${NC}  (press ${GREEN}Enter${NC} to use default port: ${CYAN}$DEFAULT_PORT${NC}):"
        echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
        read -r USER_PORT
        
        if [ -z "$USER_PORT" ]; then
            LOCAL_PORT="$DEFAULT_PORT"
        else
            LOCAL_PORT="$USER_PORT"
        fi
        
        # Save config for future runs
        echo "ENGINE=whoogle" > "$CONFIG_FILE"
        echo "IP=$LOCAL_IP" >> "$CONFIG_FILE"
        echo "PORT=$LOCAL_PORT" >> "$CONFIG_FILE"
        
        print_info "Using IP: ${LOCAL_IP:-"All interfaces (0.0.0.0)"}"
        print_info "Using port: $LOCAL_PORT"
    fi

    # Pull the Whoogle Docker image
    print_section "Pulling Docker Image"
    print_info "Pulling Whoogle Docker image..."
    docker pull benbusby/whoogle-search

    # If IP is empty, set binding to all interfaces
    BINDING_IP=${LOCAL_IP:-"0.0.0.0"}

    # Run Whoogle on the specified local IP and port
    print_section "Starting Whoogle Container"
    print_info "Running Whoogle container on $BINDING_IP:$LOCAL_PORT..."
    docker run -d \
        -p "$BINDING_IP:$LOCAL_PORT:5000" \
        --name whoogle-search \
        --restart unless-stopped \
        -e WHOOGLE_HOST="$BINDING_IP" \
        -e WHOOGLE_PORT="$LOCAL_PORT" \
        benbusby/whoogle-search

    # Create systemd service for auto-starting at boot
    print_section "Setting Up Systemd Service"
    print_info "Creating systemd service for Whoogle..."

    # Create the service file content
    cat > /etc/systemd/system/whoogle.service << EOF
[Unit]
Description=Whoogle Search Engine Container
After=docker.service network-online.target
Wants=network-online.target
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/usr/bin/docker pull benbusby/whoogle-search
ExecStart=/bin/sh -c '/usr/bin/docker start whoogle-search || /usr/bin/docker run -d -p "$BINDING_IP:$LOCAL_PORT:5000" --name whoogle-search --restart unless-stopped -e WHOOGLE_HOST="$BINDING_IP" -e WHOOGLE_PORT="$LOCAL_PORT" benbusby/whoogle-search'
ExecStop=/usr/bin/docker stop whoogle-search

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd daemon
    systemctl daemon-reload

    # Enable and start the service
    systemctl enable whoogle.service
    systemctl start whoogle.service

    # Determine the display URL
    if [ -z "$LOCAL_IP" ]; then
        DISPLAY_IP="localhost"
    else
        DISPLAY_IP="$LOCAL_IP"
    fi

    # Confirmation message
    print_section "Setup Complete"
    print_success "Whoogle setup completed"
    print_success "You can access Whoogle at: http://$DISPLAY_IP:$LOCAL_PORT"
    print_success "A systemd service has been installed to ensure Whoogle starts at boot."
    print_info "You can check its status with: systemctl status whoogle.service"
}

# Store original command for error reporting
ORIGINAL_COMMAND="$0 $*"

# Parse command-line arguments
# The leading colon in getopts suppresses default error messages
while getopts ":rh" opt; do
    case ${opt} in
        r)
            # Ensure the script is run as root for removal
            if [ "$(id -u)" != "0" ]; then
                print_error "This script must be run as root or with sudo."
                exit 1
            fi
            
            # Define CONFIG_FILE before using it in remove_search_engine
            CONFIG_FILE="/etc/private-search/config"
            remove_search_engine
            ;;
        h)
            display_help
            ;;
        :)
            print_error "Option -$OPTARG requires an argument."
            print_info "Use -h for help"
            echo
            exit 1
            ;;
        \?)
            echo
            print_error "Invalid option: '$ORIGINAL_COMMAND'"
            print_info "Use -h for help"
            echo
            exit 1
            ;;
    esac
done

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
    echo
    print_error "This script must be run as root or with sudo."
    print_info "Use -h for help"
    echo
    exit 1
fi

# Check if Docker is installed, and install it if not
if ! command -v docker &> /dev/null; then
    print_header
    print_section "Docker Installation"
    print_info "Docker not found. Installing Docker..."
    # For Debian/Ubuntu-based systems
    if command -v apt-get &> /dev/null; then
        apt-get update
        apt-get install -y docker.io
    # For Arch-based systems
    elif command -v pacman &> /dev/null; then
        pacman -Syu --noconfirm docker
    # For RHEL/CentOS/Fedora-based systems
    elif command -v yum &> /dev/null; then
        yum install -y docker
    # Other systems
    else
        print_error "Unsupported package manager. Please install Docker manually."
        exit 1
    fi
fi

# Start Docker service if it's not running
if ! systemctl is-active --quiet docker; then
    print_section "Starting Docker Service"
    print_info "Starting Docker service..."
    systemctl start docker
    systemctl enable docker
fi

# Show menu and get user choice
show_search_menu

# Call appropriate setup function based on user choice
if [ "$SEARCH_ENGINE" = "searxng" ]; then
    setup_searxng
elif [ "$SEARCH_ENGINE" = "whoogle" ]; then
    setup_whoogle
fi
