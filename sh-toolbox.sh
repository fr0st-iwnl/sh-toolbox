#!/bin/bash

# sh-toolbox.sh
#
# A collection of useful shell tools.
#
# Author: @fr0st-iwnl
#=================================================================
# Repository: https://github.com/fr0st-iwnl/sh-toolbox
#-----------------------------------------------------------------
# Issues: https://github.com/fr0st-iwnl/sh-toolbox/issues/
# Pull Requests: https://github.com/fr0st-iwnl/sh-toolbox/pulls
#-----------------------------------------------------------------

# Colors :)
GREEN='\033[0;32m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
LIGHT_BLUE='\033[1;34m'
MID_BLUE='\033[38;2;30;144;255m'  # DodgerBlue
YELLOW='\033[0;33m'
PURPLE='\033[0;35m'
MAGENTA='\033[1;35m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to display the welcome message
show_welcome() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "  ___ _  _         _____ ___   ___  _    ___  _____  __"
    echo " / __| || |  ___  |_   _/ _ \ / _ \| |  | _ )/ _ \ \/ /"
    echo " \__ \ __ | |___|   | || (_) | (_) | |__| _ \ (_) >  < "
    echo " |___/_||_|         |_| \___/ \___/|____|___/\___/_/\_\\"
    echo "                                                       "
    echo -e "${NC}"
    echo -e "${CYAN}Welcome to sh-toolbox - A collection of useful shell tools${NC}"
    echo
    echo -e "${YELLOW}Version: ${NC}1.4"
    echo -e "${YELLOW}GitHub: ${NC}https://github.com/fr0st-iwnl/sh-toolbox"
    echo
}

# Function to display the help menu
show_help() {
    echo
    echo -e "${BOLD}${BLUE}Options:${NC}"
    echo
    echo -e "  ${GREEN}-h, --help${NC}      - Display this help menu"
    echo -e "  ${GREEN}-i, --install${NC}   - Run the sh-toolbox installer"
    echo -e "  ${GREEN}-u, --uninstall${NC} - Uninstall sh-toolbox"
    echo -e "  ${GREEN}-c, --commands${NC}  - Display available commands"
    echo -e "  ${GREEN}-k, --keybind${NC}   - Manage keybindings using sxhkd"
    echo -e "  ${GREEN}-p, --update${NC}    - Check for updates to sh-toolbox"
    echo 
}

# Animation function
animate_progress() {
    local msg="$1"
    echo -ne "${YELLOW}[   ] ${msg}...${NC}\r"
    sleep 0.1
    echo -ne "${YELLOW}[.  ] ${msg}...${NC}\r"
    sleep 0.1
    echo -ne "${YELLOW}[.. ] ${msg}...${NC}\r"
    sleep 0.1
}

# Success message function
show_success() {
    local msg="$1"
    echo -e "${GREEN}[✓] ${msg}${NC}"
}

# Error message function
show_error() {
    local msg="$1"
    echo -e "${RED}[✗] ${msg}${NC}" >&2
}

# Function to create a sudo wrapper for scripts that need root permissions
create_sudo_wrapper() {
    local script_name="$1"
    local script_path="$2"
    
    # Create wrapper script
    cat > "temp-wrapper" << EOF
#!/bin/bash
if [ "\$(id -u)" != "0" ]; then
    echo -e "\033[0;33m[!] This tool requires root privileges to run.\033[0m"
    echo -e "\033[0;33m[!] You will be prompted for your password.\033[0m"
    exec sudo "$script_path" "\$@"
else
    exec "$script_path" "\$@"
fi
EOF
    
    # Set it as executable
    chmod +x "temp-wrapper"
    
    # Install it system-wide quietly
    if sudo mv "temp-wrapper" "/usr/local/bin/$script_name" 2>/dev/null; then
        return 0
    else
        rm -f "temp-wrapper"
        return 1
    fi
}

# Function to run the installer
run_installer() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│      Shell Tools Installer        │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"

    # Check if running from the correct directory
    if [ ! -d "NetInfo" ] || [ ! -d "Quotes" ] || [ ! -d "Remind Me" ] || [ ! -d "Weather" ] || [ ! -d "System Update" ] || [ ! -d "Random Wallpaper" ] || [ ! -d "Keybindings" ] || [ ! -d "PrivateSearch" ]; then
        show_error "Missing required directories. Please run this script from the sh-toolbox root directory"
        exit 1
    fi

    # 1. Create bin directory if it doesn't exist
    animate_progress "Creating bin directory"
    mkdir -p "$HOME/.local/share/bin"
    show_success "Created bin directory at ~/.local/share/bin"
    echo

    # 2. Copy each script to bin directory with appropriate name
    echo -e "${BOLD}Installing tools:${NC}"

    animate_progress "Installing main sh-toolbox script"
    cp "$(pwd)/sh-toolbox.sh" "$HOME/.local/share/bin/sh-toolbox"
    chmod +x "$HOME/.local/share/bin/sh-toolbox"
    show_success "sh-toolbox main script installed as 'sh-toolbox'"

    animate_progress "Installing NetInfo tool"
    cp "$(pwd)/NetInfo/netinfo.sh" "$HOME/.local/share/bin/netinfo"
    chmod +x "$HOME/.local/share/bin/netinfo"
    show_success "NetInfo installed as 'netinfo'"

    animate_progress "Installing Remind Me tool"
    cp "$(pwd)/Remind Me/remind-me.sh" "$HOME/.local/share/bin/remind-me"
    chmod +x "$HOME/.local/share/bin/remind-me"
    show_success "Remind Me installed as 'remind-me'"


    animate_progress "Installing Quote tool"
    cp "$(pwd)/Quotes/quote.sh" "$HOME/.local/share/bin/quote"
    chmod +x "$HOME/.local/share/bin/quote"
    show_success "Quotes installed as 'quote'"

    animate_progress "Installing System Update tool"
    cp "$(pwd)/System Update/update.sh" "$HOME/.local/share/bin/update"
    chmod +x "$HOME/.local/share/bin/update"
    show_success "System Update installed as 'update'"

    animate_progress "Installing Weather tool"
    cp "$(pwd)/Weather/weather.sh" "$HOME/.local/share/bin/weather"
    chmod +x "$HOME/.local/share/bin/weather"
    show_success "Weather installed as 'weather'"

    animate_progress "Installing Random Wallpaper tool"
    cp "$(pwd)/Random Wallpaper/random-wall.sh" "$HOME/.local/share/bin/random-wall"
    chmod +x "$HOME/.local/share/bin/random-wall"
    show_success "Random Wallpaper installed as 'random-wall'"
    
    animate_progress "Installing Keybind tool"
    cp "$(pwd)/Keybindings/keybind.sh" "$HOME/.local/share/bin/keybind"
    chmod +x "$HOME/.local/share/bin/keybind"
    show_success "Keybind tool installed as 'keybind'"
    
    animate_progress "Installing PrivateSearch tool"
    cp "$(pwd)/PrivateSearch/private-search.sh" "$HOME/.local/share/bin/private-search-script"
    chmod +x "$HOME/.local/share/bin/private-search-script"
    
    # Create a proper wrapper for private-search
    cat > "$HOME/.local/share/bin/private-search" << EOF
#!/bin/bash

# Colors
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [ "\$(id -u)" != "0" ]; then
    # Check if sudo credentials are already cached
    if ! sudo -n true 2>/dev/null; then
        # Only show password prompt message if credentials aren't cached
        echo -e "\${YELLOW}[!] PrivateSearch requires root privileges to run.\${NC}"
        echo -e "\${YELLOW}[!] You will be prompted for your password.\${NC}"
    fi
    sudo "\$0" "\$@"
    exit \$?
else
    # When running as root, execute the actual script
    exec "$HOME/.local/share/bin/private-search-script" "\$@"
fi
EOF
    chmod +x "$HOME/.local/share/bin/private-search"
    show_success "PrivateSearch installed as 'private-search'"
    
    # Create Keybindings directory in the bin location
    animate_progress "Installing Keybinding scripts"
    mkdir -p "$HOME/.local/share/bin/Keybindings"
    
    # Copy the required keybinding utility scripts
    cp "$(pwd)/Keybindings/toggle_mic.sh" "$HOME/.local/share/bin/Keybindings/"
    cp "$(pwd)/Keybindings/toggle_audio.sh" "$HOME/.local/share/bin/Keybindings/"
    cp "$(pwd)/Keybindings/volume_up.sh" "$HOME/.local/share/bin/Keybindings/"
    cp "$(pwd)/Keybindings/volume_down.sh" "$HOME/.local/share/bin/Keybindings/"
    
    # Make them executable
    chmod +x "$HOME/.local/share/bin/Keybindings/"*.sh
    show_success "Keybinding utility scripts installed"
    echo

    # 3. Update PATH in shell configuration
    echo -e "${BOLD}Configuring shell:${NC}"
    shell_config=""
    if [ -f "$HOME/.bashrc" ]; then
        shell_config="$HOME/.bashrc"
    elif [ -f "$HOME/.zshrc" ]; then
        shell_config="$HOME/.zshrc"
    else
        show_error "Could not find .bashrc or .zshrc. You'll need to update your PATH manually"
        exit 1
    fi

    animate_progress "Updating PATH in $shell_config"
    if ! grep -q 'export PATH="$HOME/.local/share/bin:$PATH"' "$shell_config"; then
        echo '' >> "$shell_config"
        echo '' >> "$shell_config"
        echo '# Added by sh-toolbox installation script' >> "$shell_config"
        echo 'export PATH="$HOME/.local/share/bin:$PATH"' >> "$shell_config"
        show_success "PATH updated in $shell_config"
    else
        show_success "PATH already configured in $shell_config"
    fi
    echo

    # Print usage information
    echo -e "${BOLD}${MID_BLUE}┌───────────────────────────────────┐"
    echo -e "│      Installation Complete!       │"
    echo -e "└───────────────────────────────────┘"
    echo -e "${NC}"

    echo -e "${BOLD}${GREEN}[✓] Now run '${NC}sh-toolbox -c${GREEN}' to get started!${NC}"
    echo -e "${YELLOW}[!] Note: You may need to restart your terminal for changes to take effect.${NC}"
    echo
}

# Function to uninstall sh-toolbox
run_uninstaller() {
    echo -e "${BOLD}${RED}"
    echo "┌───────────────────────────────────┐"
    echo "│      Uninstalling sh-toolbox      │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"

    # Confirm uninstallation
    echo -e "${GREEN} This will remove all sh-toolbox scripts from your system.${NC}"
    echo -e "${YELLOW}╭─ Are you sure you want to continue? [y/N]${NC}"
    echo -ne "${BOLD}${YELLOW}╰─➤ ${NC}"
    read -r answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Uninstallation cancelled.${NC}"
        exit 0
    fi

    echo

    # Stop sxhkd process if it's running
    animate_progress "Stopping sxhkd process"
    if pgrep -x sxhkd > /dev/null; then
        # Try to kill the process
        pkill -x sxhkd
        sleep 1
        
        # Check if it's still running and force kill if needed
        if pgrep -x sxhkd > /dev/null; then
            pkill -9 -x sxhkd
            sleep 1
        fi
        
        # Verify it's stopped
        if pgrep -x sxhkd > /dev/null; then
            echo -e "${YELLOW}[!] Warning: Could not stop sxhkd process. Your keybindings may remain active.${NC}"
            echo -e "${YELLOW}    You can manually stop it with: pkill -9 sxhkd${NC}"
        else
            show_success "Stopped sxhkd process"
        fi
    else
        show_success "No running sxhkd process found"
    fi

    # Disable and remove systemd service for sxhkd if it exists
    animate_progress "Checking sxhkd systemd service"
    SYSTEMD_SERVICE_FILE="$HOME/.config/systemd/user/sxhkd.service"
    if [ -f "$SYSTEMD_SERVICE_FILE" ]; then
        echo -e "${YELLOW}Found sxhkd systemd service. Disabling and removing...${NC}"
        
        # Stop the service if it's running
        if systemctl --user is-active sxhkd.service &>/dev/null; then
            echo -e "${YELLOW}Stopping sxhkd service...${NC}"
            systemctl --user stop sxhkd.service &>/dev/null
        fi
        
        # Try to disable the service
        systemctl --user disable sxhkd.service &>/dev/null
        
        # Then remove the service file
        rm -f "$SYSTEMD_SERVICE_FILE" &>/dev/null
        
        # Clean up the wants directory if it's empty
        rmdir --ignore-fail-on-non-empty "$HOME/.config/systemd/user/default.target.wants" &>/dev/null
        
        show_success "Removed sxhkd systemd service"
    else
        # Even if the service file doesn't exist, check if the service is running and stop it
        if systemctl --user is-active sxhkd.service &>/dev/null; then
            echo -e "${YELLOW}Stopping running sxhkd service...${NC}"
            systemctl --user stop sxhkd.service &>/dev/null
            show_success "Stopped sxhkd service"
        else
            show_success "No sxhkd systemd service found"
        fi
    fi

    # Remove scripts from bin directory
    animate_progress "Removing sh-toolbox scripts"
    rm -f "$HOME/.local/share/bin/sh-toolbox" 2>/dev/null
    rm -f "$HOME/.local/share/bin/netinfo" 2>/dev/null
    rm -f "$HOME/.local/share/bin/remind-me" 2>/dev/null
    rm -f "$HOME/.local/share/bin/quote" 2>/dev/null
    rm -f "$HOME/.local/share/bin/update" 2>/dev/null
    rm -f "$HOME/.local/share/bin/weather" 2>/dev/null
    rm -f "$HOME/.local/share/bin/random-wall" 2>/dev/null
    rm -f "$HOME/.local/share/bin/keybind" 2>/dev/null
    rm -f "$HOME/.local/share/bin/private-search" 2>/dev/null
    rm -f "$HOME/.local/share/bin/private-search-script" 2>/dev/null
    rm -rf "$HOME/.local/share/bin/Keybindings" 2>/dev/null
    
    # Handle PrivateSearch sudo wrapper without requiring password
    if [ -f "/usr/local/bin/private-search" ]; then
        animate_progress "Checking for PrivateSearch sudo wrapper"
        echo
        echo -e "${YELLOW}[!] Found PrivateSearch sudo wrapper at /usr/local/bin/private-search${NC}"
        echo -e "${YELLOW}╭─ Do you want to remove it now? (requires sudo password) [Y/n]:${NC}"
        echo -ne "${BOLD}${YELLOW}╰─➤ ${NC}"
        read -r remove_wrapper
        
        if [[ ! "$remove_wrapper" =~ ^[Nn]$ ]]; then
            echo -e "${YELLOW}Removing sudo wrapper...${NC}"
            if sudo rm -f "/usr/local/bin/private-search" 2>/dev/null; then
                echo -e "${GREEN}[✓] Successfully removed PrivateSearch sudo wrapper${NC}"
            else
                echo -e "${RED}[✗] Failed to remove sudo wrapper${NC}"
                echo -e "${YELLOW}    You can remove it manually later with: sudo rm /usr/local/bin/private-search${NC}"
            fi
        else
            echo -e "${YELLOW}[!] Skipping removal of sudo wrapper${NC}"
            echo -e "${YELLOW}    You can remove it manually later with: sudo rm /usr/local/bin/private-search${NC}"
        fi
    fi
    
    show_success "Removed all sh-toolbox scripts"
    
    # Remove config directories
    animate_progress "Removing configuration files"
    
    # Remove sxhkd directory completely
    if [ -d "$HOME/.config/sxhkd" ]; then
        rm -rf "$HOME/.config/sxhkd" 2>/dev/null
    fi
    
    # Remove sh-toolbox config directory
    if [ -d "$HOME/.config/sh-toolbox" ]; then
        rm -rf "$HOME/.config/sh-toolbox" 2>/dev/null
    fi
    
    show_success "Removed all configuration files"

    # Clean up PATH in shell configuration if bin directory is empty
    if [ -z "$(ls -A "$HOME/.local/share/bin" 2>/dev/null)" ]; then
        animate_progress "Checking shell configuration"
        shell_config=""
        if [ -f "$HOME/.bashrc" ]; then
            shell_config="$HOME/.bashrc"
        elif [ -f "$HOME/.zshrc" ]; then
            shell_config="$HOME/.zshrc"
        fi

        if [ -n "$shell_config" ]; then
            # Remove the PATH entry and comment only if they were added by sh-toolbox
            sed -i '/# Added by sh-toolbox installation script/d' "$shell_config" 2>/dev/null
            sed -i '/export PATH="$HOME\/.local\/share\/bin:$PATH"/d' "$shell_config" 2>/dev/null
            
            # Clean up any extra empty lines (save to temp file and move back)
            awk 'NF > 0 || NR == 1 {blank=0} NF==0 {blank++} blank <= 1' "$shell_config" > "${shell_config}.tmp"
            mv "${shell_config}.tmp" "$shell_config"
            
            show_success "Cleaned up shell configuration in $shell_config"
        fi
    else
        show_success "Kept bin directory in PATH since other tools are still using it"
    fi

    echo
    echo -e "${BOLD}${CYAN}┌───────────────────────────────────┐"
    echo -e "│      Uninstallation Complete!     │"
    echo -e "└───────────────────────────────────┘"
    echo -e "${NC}"
    echo
    echo -e "${BOLD}${GREEN}[✓] sh-toolbox has been removed from your system.${NC}"
    echo -e "${YELLOW}[!] Note: You may need to restart your terminal for changes to take effect.${NC}"
    echo
}

# Function to run a command
run_command() {
    command_to_run="$1"
    
    if [ -z "$command_to_run" ]; then
        echo -e "${RED}[✗] No command provided.${NC}" >&2
        return 1
    fi
    
    # Check if it's a simple command (single word)
    if [[ "$command_to_run" =~ ^[a-zA-Z0-9_\-]+$ ]]; then
        # Check if it exists as an application
        if ! command -v "$command_to_run" &> /dev/null; then
            echo -e "${YELLOW}[!] Warning: '$command_to_run' does not appear to be installed or in your PATH.${NC}"
            echo -e "${YELLOW}It may not work unless it's a built-in shell command or script.${NC}"
            echo -e "${BOLD}Continue anyway? [Y/n]:${NC}"
            read -r continue_anyway
            if [[ "$continue_anyway" =~ ^[Nn]$ ]]; then
                echo -e "${RED}[✗] Command execution cancelled.${NC}" >&2
                return 1
            fi
        else
            echo -e "${GREEN}[✓] Found '$command_to_run' in your PATH.${NC}"
        fi
    fi
    
    # Ask about notification
    echo -e "${YELLOW}Would you like to receive a notification when the command runs? [y/N]:${NC}"
    read -r notify_choice
    
    if [[ "$notify_choice" =~ ^[Yy]$ ]] && command -v notify-send &> /dev/null; then
        # Run with notification
        notify-send "Running command" "$command_to_run"
        eval "$command_to_run"
    else
        # Run without notification
        eval "$command_to_run"
    fi
    
    echo -e "${GREEN}[✓] Executed: $command_to_run${NC}"
    return 0
}

# Function to check for updates and update sh-toolbox
check_for_updates() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│      Checking for Updates         │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"

    # Current version (extracted from the script)
    CURRENT_VERSION=$(grep -oP 'Version: \${NC}\K[0-9]+\.[0-9]+' "$0" 2>/dev/null || echo "")
    
    if [ -z "$CURRENT_VERSION" ]; then
        # Try alternative pattern
        CURRENT_VERSION=$(grep -oP 'echo -e.*Version: \${NC}\K[0-9]+\.[0-9]+' "$0" 2>/dev/null || echo "")
        if [ -z "$CURRENT_VERSION" ]; then
            CURRENT_VERSION="unknown"
            show_error "Could not determine current version, assuming outdated."
        fi
    fi
    
    echo -e "${CYAN}Current version:${NC} $CURRENT_VERSION"
    
    
    # Check if curl or wget is available
    if command -v curl &>/dev/null; then
        # echo -e "${YELLOW}Checking for latest version...${NC}"
        LATEST_VERSION=$(curl -s https://sh-toolbox.netlify.app/version.txt | tr -d '\r\n')
    elif command -v wget &>/dev/null; then
        # echo -e "${YELLOW}Checking for latest version...${NC}"
        LATEST_VERSION=$(wget -qO- https://sh-toolbox.netlify.app/version.txt | tr -d '\r\n')
    else
        show_error "Neither curl nor wget found. Cannot check for updates."
        exit 1
    fi
    
    if [ -z "$LATEST_VERSION" ]; then
        show_error "Failed to retrieve latest version."
        exit 1
    fi
    
    echo -e "${CYAN}Latest version:${NC} $LATEST_VERSION"
    echo
    
    # Compare versions (simple string comparison for now)
    if [ "$CURRENT_VERSION" = "$LATEST_VERSION" ]; then
        show_success "You are running the latest version of sh-toolbox!"
        exit 0
    fi
    
    # If we get here, there is a newer version
    echo -e "${YELLOW}A new version ($LATEST_VERSION) is available. You have version $CURRENT_VERSION.${NC}"
    echo
    echo -e "${YELLOW}Update options:${NC}"
    echo -e "  ${GREEN}1)${NC} Automatic update (download and directly extract over current files)"
    echo -e "  ${GREEN}2)${NC} Manual update (open browser to download the latest release)"
    echo -e "  ${GREEN}3)${NC} Cancel"
    echo
    echo -e "${BOLD}${BLUE}╭─ Choose an option (1-3):${NC}"
    echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
    read -r update_choice
    
    case $update_choice in
        1)
            # Automatic update
            echo
            echo -e "${CYAN}Starting automatic update to version $LATEST_VERSION...${NC}"
            
            # Get the script's directory
            SCRIPT_DIR=$(dirname "$(realpath "$0")")
            cd "$SCRIPT_DIR" || exit 1
            
            # Download the release ZIP file directly
            DOWNLOAD_URL="https://github.com/fr0st-iwnl/sh-toolbox/releases/download/$LATEST_VERSION/sh-toolbox.zip"
            echo -e "${YELLOW}Downloading from: $DOWNLOAD_URL${NC}"
            
            if command -v curl &>/dev/null; then
                curl -L -o sh-toolbox.zip "$DOWNLOAD_URL"
                DOWNLOAD_SUCCESS=$?
            elif command -v wget &>/dev/null; then
                wget -q "$DOWNLOAD_URL" -O sh-toolbox.zip
                DOWNLOAD_SUCCESS=$?
            else
                show_error "Neither curl nor wget found. Cannot download updates."
                exit 1
            fi
            
            # Check download success
            if [ $DOWNLOAD_SUCCESS -ne 0 ]; then
                show_error "Failed to download the latest version."
                exit 1
            fi
            
            echo -e "${YELLOW}Download complete. Extracting directly over current directory...${NC}"
            
            # Extract the ZIP file
            if ! command -v unzip &>/dev/null; then
                show_error "Unzip command not found. Please install unzip and try again."
                rm -f sh-toolbox.zip
                exit 1
            fi
            
            # First extract to a temporary directory to handle different folder structures
            TMP_EXTRACT_DIR=$(mktemp -d)
            unzip -q sh-toolbox.zip -d "$TMP_EXTRACT_DIR"
            if [ $? -ne 0 ]; then
                show_error "Failed to extract the update package."
                rm -f sh-toolbox.zip
                rm -rf "$TMP_EXTRACT_DIR"
                exit 1
            fi
            
            # Find the sh-toolbox directory within the extracted files
            MAIN_DIR=""
            if [ -d "$TMP_EXTRACT_DIR/sh-toolbox" ]; then
                MAIN_DIR="$TMP_EXTRACT_DIR/sh-toolbox"
            else
                # Try to find it if named differently
                for dir in "$TMP_EXTRACT_DIR"/*; do
                    if [ -d "$dir" ] && [ -f "$dir/sh-toolbox.sh" ]; then
                        MAIN_DIR="$dir"
                        break
                    fi
                done
            fi
            
            if [ -z "$MAIN_DIR" ] || [ ! -f "$MAIN_DIR/sh-toolbox.sh" ]; then
                # If we couldn't find a subdirectory with sh-toolbox.sh, check if it's directly in the TMP_EXTRACT_DIR
                if [ -f "$TMP_EXTRACT_DIR/sh-toolbox.sh" ]; then
                    MAIN_DIR="$TMP_EXTRACT_DIR"
                else
                    show_error "Could not find sh-toolbox.sh in the extracted files."
                    rm -f sh-toolbox.zip
                    rm -rf "$TMP_EXTRACT_DIR"
                    exit 1
                fi
            fi
            
            # Now copy all the files to current directory 
            echo -e "${YELLOW}Copying updated files...${NC}"
            cp -r "$MAIN_DIR"/* ./
            
            # Make all scripts executable
            chmod +x sh-toolbox.sh
            find . -name "*.sh" -type f -exec chmod +x {} \;
            
            # Clean up
            rm -f sh-toolbox.zip
            rm -rf "$TMP_EXTRACT_DIR"
            
            echo
            echo -e "${BOLD}${MID_BLUE}┌───────────────────────────────────┐"
            echo -e "│        Update Complete!           │"
            echo -e "└───────────────────────────────────┘"
            echo -e "${NC}"
            echo -e "${GREEN}[✓] sh-toolbox has been updated to version $LATEST_VERSION${NC}"
            echo
            ;;
            
        2)
            # Manual update - provide links
            echo
            echo -e "${CYAN}Manual Update Instructions:${NC}"
            echo -e "1. Download the latest release from:"
            echo -e "   ${GREEN}https://github.com/fr0st-iwnl/sh-toolbox/releases/download/$LATEST_VERSION/sh-toolbox.zip${NC}"
            echo -e "2. Extract the ZIP file into your current directory"
            echo
            echo -e "${YELLOW}Would you like to open the download link in your browser? [Y/n]${NC}"
            echo -ne "${BOLD}${YELLOW}╰─➤ ${NC}"
            read -r open_browser
            
            if [[ ! "$open_browser" =~ ^[Nn]$ ]]; then
                # Try to open the browser
                URL="https://github.com/fr0st-iwnl/sh-toolbox/releases/download/$LATEST_VERSION/sh-toolbox.zip"
                
                if command -v xdg-open &>/dev/null; then
                    xdg-open "$URL"
                elif command -v open &>/dev/null; then
                    open "$URL"
                elif command -v start &>/dev/null; then
                    start "$URL"
                else
                    echo -e "${RED}[✗] Couldn't open a browser automatically.${NC}"
                    echo -e "${YELLOW}Please manually visit:${NC}"
                    echo -e "${GREEN}$URL${NC}"
                fi
            fi
            ;;
            
        3|*)
            # Cancel or invalid choice
            echo -e "${GREEN}Oki!${NC}"
            exit 0
            ;;
    esac
}

# Main function to process arguments
main() {
    # Process arguments
    case "$1" in
        -h|--help)
            show_help
            ;;
        -i|--install)
            run_installer
            ;;
        -u|--uninstall)
            run_uninstaller
            ;;
        -p|--update)
            check_for_updates
            ;;
        -k|--keybind)
            # Run keybind manager with remaining arguments
            shift
            # Determine if we're running from installed or local
            if [[ "$(realpath "$0")" == *"/.local/share/bin/"* ]]; then
                # We're running from the installed location
                # Set the script directory to the current repo directory
                repo_dir="$(realpath "$(dirname "$0")")"
                # Find the Keybindings directory from the current source tree
                if [ -d "$repo_dir/Keybindings" ]; then
                    # Installed version has keybinding scripts in the same directory
                    KEYBIND_SCRIPTS_DIR="$repo_dir/Keybindings" "$HOME/.local/share/bin/keybind" "$@"
                elif [ -d "/usr/local/share/sh-toolbox/Keybindings" ]; then
                    # Check system-wide installation location
                    KEYBIND_SCRIPTS_DIR="/usr/local/share/sh-toolbox/Keybindings" "$HOME/.local/share/bin/keybind" "$@"
                elif [ -d "$HOME/.local/share/sh-toolbox/Keybindings" ]; then
                    # Check user-specific installation location
                    KEYBIND_SCRIPTS_DIR="$HOME/.local/share/sh-toolbox/Keybindings" "$HOME/.local/share/bin/keybind" "$@"
                else
                    # Last resort - use the directory containing the keybind script
                    keybind_script_dir="$(dirname "$(realpath "$HOME/.local/share/bin/keybind")")"
                    KEYBIND_SCRIPTS_DIR="$keybind_script_dir" "$HOME/.local/share/bin/keybind" "$@"
                fi
            else
                # We're running from the repository, get the absolute path
                repo_dir="$(realpath "$(dirname "$0")")"
                KEYBIND_SCRIPTS_DIR="$repo_dir/Keybindings" "$repo_dir/Keybindings/keybind.sh" "$@"
            fi
            ;;
        -c|--commands)
            # Only show commands, remove ability to run them
            echo
            echo -e "${BOLD}${BLUE}Available Commands:${NC}"
            echo
            echo -e "  ${GREEN}quote${NC}      - Show random inspirational quotes"
            echo -e "  ${GREEN}update${NC}     - Update system packages (Arch Linux with AUR and Flatpak support)"
            echo -e "  ${GREEN}weather${NC}    - Show current weather information for your location"
            echo -e "  ${GREEN}netinfo${NC}    - Display detailed network information (IP, speeds, latency)"
            echo -e "  ${GREEN}random-wall${NC} - Set a random wallpaper from a directory"
            echo -e "  ${GREEN}remind-me${NC}  - Set reminders for yourself"
            echo -e "  ${GREEN}keybind${NC}    - Manage keybindings using sxhkd"
            echo -e "  ${GREEN}private-search${NC} - Install and configure a private search engine"
            echo
            ;;
        
        *)
            # Display welcome message and brief info for no arguments
            if [ $# -eq 0 ]; then
                show_welcome
                echo -e "${BOLD}${MID_BLUE}Quick Start:${NC}"
                echo -e "  1. Run ${GREEN}./sh-toolbox -i${NC} to install sh-toolbox"
                echo -e "  2. Run ${GREEN}./sh-toolbox -c${NC} to see all available commands"
                echo -e "  3. Run ${GREEN}./sh-toolbox -p${NC} to check for updates"
                echo -e "  4. Run ${GREEN}./sh-toolbox -h${NC} for detailed help"
                echo
            else
                echo
                echo -e "${RED}[✗] Unknown option:${NC} $1"
                echo -e "Use ${MID_BLUE}sh-toolbox --help${NC} to see available options"
                echo
                exit 1
            fi
            ;;
    esac
}

# Run the main function with all arguments
main "$@"
