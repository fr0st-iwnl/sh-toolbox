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

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
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
    echo -e "${YELLOW}Version: ${NC}1.0"
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
    echo -e "  ${GREEN}-c, --commands${NC}  - Display available commands"
    echo -e "  ${GREEN}-u, --uninstall${NC} - Uninstall sh-toolbox"
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

# Function to run the installer
run_installer() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│      Shell Tools Installer        │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"

    # Check if running from the correct directory
    if [ ! -d "NetInfo" ] || [ ! -d "Quotes" ] || [ ! -d "Weather" ] || [ ! -d "System Update" ] || [ ! -d "Random Wallpaper" ]; then
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
    echo

    animate_progress "Installing Random Wallpaper tool"
    cp "$(pwd)/Random Wallpaper/random-wall.sh" "$HOME/.local/share/bin/random-wall"
    chmod +x "$HOME/.local/share/bin/random-wall"
    show_success "Random Wallpaper installed as 'random-wall'"
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
    echo -e "${YELLOW}This will remove all sh-toolbox scripts from your system.${NC}"
    echo -e "${YELLOW}Are you sure you want to continue? [y/N]${NC}"
    read -r answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Uninstallation cancelled.${NC}"
        exit 0
    fi

    echo

    # Remove scripts from bin directory
    animate_progress "Removing sh-toolbox scripts"
    rm -f "$HOME/.local/share/bin/sh-toolbox" 2>/dev/null
    rm -f "$HOME/.local/share/bin/netinfo" 2>/dev/null
    rm -f "$HOME/.local/share/bin/quote" 2>/dev/null
    rm -f "$HOME/.local/share/bin/update" 2>/dev/null
    rm -f "$HOME/.local/share/bin/weather" 2>/dev/null
    rm -f "$HOME/.local/share/bin/random-wall" 2>/dev/null
    show_success "Removed all sh-toolbox scripts"

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
    echo -e "${BOLD}${RED}┌───────────────────────────────────┐"
    echo -e "│      Uninstallation Complete!     │"
    echo -e "└───────────────────────────────────┘"
    echo -e "${NC}"
    echo
    echo -e "${BOLD}${GREEN}[✓] sh-toolbox has been removed from your system.${NC}"
    echo -e "${YELLOW}[!] Note: You may need to restart your terminal for changes to take effect.${NC}"
    echo
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
        -c|--commands)
            # Show only the commands without welcome message
            echo
            echo -e "${BOLD}${BLUE}Available Commands:${NC}"
            echo
            echo -e "  ${GREEN}netinfo${NC}    - Display detailed network information (IP, speeds, latency)"
            echo -e "  ${GREEN}quote${NC}      - Show random inspirational quotes"
            echo -e "  ${GREEN}update${NC}     - Update system packages (Arch Linux with AUR and Flatpak support)"
            echo -e "  ${GREEN}weather${NC}    - Show current weather information for your location"
            echo -e " ${GREEN}random-wall${NC} - Set a random wallpaper from a directory"
            ;;
        *)
            # Display welcome message and brief info for no arguments
            if [ $# -eq 0 ]; then
                show_welcome
                echo -e "${BOLD}${MID_BLUE}Quick Start:${NC}"
                echo -e "  1. Run ${GREEN}./sh-toolbox -i${NC} to install sh-toolbox"
                echo -e "  2. Run ${GREEN}./sh-toolbox -c${NC} to see all available commands"
                echo -e "  3. Run ${GREEN}./sh-toolbox -h${NC} for detailed help"
                echo
            else
                echo -e "${RED}Unknown option: $1${NC}"
                echo -e "Use ${GREEN}./sh-toolbox -h${NC} to see available options"
                exit 1
            fi
            ;;
    esac
}

# Run the main function with all arguments
main "$@"
