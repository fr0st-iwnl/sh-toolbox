#!/usr/bin/env bash

# update.sh
# A simple script for managing system updates across various Linux distributions,
# including support for AUR, Flatpak, and common package managers
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
BRIGHT_RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[38;2;152;251;152m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
MID_BLUE='\033[38;2;135;206;250m'
SECOND_BLUE='\033[1;34m'
SECOND_GREEN='\033[1;32m'
NC='\033[0m' # No Color

# Parse command line options
TIME_UPDATE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--time)
            TIME_UPDATE=true
            shift
            ;;
        -h|--help)
            echo -e "${BOLD}${MID_BLUE}"
            echo "┌───────────────────────────────────┐"
            echo "│        SYSTEM UPDATE HELP         │"
            echo "└───────────────────────────────────┘"
            echo -e "${NC}"
            echo -e "${SECOND_BLUE}Options:${NC}"
            echo -e "  ${SECOND_GREEN}-h, --help${NC}        Display this help message"
            echo -e "  ${SECOND_GREEN}-t, --time${NC}        Count the time for the update"
            echo
            exit 0
            ;;
        *)
            # Unknown option
            echo
            echo -e "${RED}[✗] Unknown option:${NC} $1"
            echo -e "Run ${MID_BLUE}update --help${NC} for usage information."
            echo
            exit 1
            ;;
    esac
done

# Detect distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    DISTRO=$ID
elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    DISTRO=$DISTRIB_ID
else
    echo -e "${RED}${BOLD}Unable to detect Linux distribution.${NC}"
    exit 1
fi

# Function to check if a package is installed based on distribution
pkg_installed() {
    case $DISTRO in
        arch|manjaro|endeavouros)
            pacman -Qq "$1" &> /dev/null
            ;;
        debian|ubuntu|linuxmint|pop)
            dpkg -l "$1" &> /dev/null
            ;;
        fedora|centos|rhel)
            rpm -q "$1" &> /dev/null
            ;;
        opensuse*|suse*)
            rpm -q "$1" &> /dev/null
            ;;
        *)
            echo -e "${RED}Unsupported distribution for package check: ${BOLD}$DISTRO${NC}"
            return 1
            ;;
    esac
}

# Function to count pending updates
count_updates() {
    case $DISTRO in
        arch|manjaro|endeavouros)
            if pkg_installed pacman-contrib; then
                (while pgrep -x checkupdates > /dev/null ; do sleep 1; done) ; checkupdates | wc -l
            else
                echo -e "${YELLOW}Not checked (pacman-contrib missing)${NC}"
            fi
            ;;
        debian|ubuntu|linuxmint|pop)
            apt list --upgradable 2>/dev/null | grep -v "Listing..." | wc -l
            ;;
        fedora)
            dnf check-update --quiet | wc -l
            ;;
        centos|rhel)
            yum check-update --quiet | wc -l
            ;;
        opensuse*|suse*)
            zypper list-updates | grep '^v' | wc -l
            ;;
        *)
            echo -e "${RED}Not supported${NC}"
            ;;
    esac
}

update_system() {
    local start_time=0
    
    if [ "$TIME_UPDATE" = true ]; then
        start_time=$(date +%s)
        echo -e "\n${BOLD}${CYAN}Starting timed update at $(date +"%T")...${NC}\n"
    else
        echo -e "\n${BOLD}${GREEN}Starting the system update...${NC}\n"
    fi

    # Update official packages
    echo -e "${CYAN}${BOLD}Updating official packages...${NC}"
    
    case $DISTRO in
        arch|manjaro|endeavouros)
            sudo pacman -Syu
            
            # Update AUR packages
            if pkg_installed yay; then
                echo -e "\n${MAGENTA}${BOLD}Updating AUR packages using yay...${NC}"
                yay -Syu
            elif pkg_installed paru; then
                echo -e "\n${MAGENTA}${BOLD}Updating AUR packages using paru...${NC}"
                paru -Syu
            else
                echo -e "\n${YELLOW}AUR helper not installed, skipping AUR updates.${NC}"
            fi
            ;;
        debian|ubuntu|linuxmint|pop)
            sudo apt update && sudo apt upgrade -y
            ;;
        fedora)
            sudo dnf upgrade -y
            ;;
        centos|rhel)
            sudo yum update -y
            ;;
        opensuse*|suse*)
            sudo zypper update -y
            ;;
        *)
            echo -e "${RED}Unsupported distribution for system update: ${BOLD}$DISTRO${NC}"
            ;;
    esac

    # Update Flatpak packages
    if pkg_installed flatpak || command -v flatpak &>/dev/null; then
        echo -e "\n${BLUE}${BOLD}Updating Flatpak packages...${NC}"
        flatpak update -y
    else
        echo -e "\n${YELLOW}Flatpak not installed, skipping Flatpak updates.${NC}"
    fi

    if [ "$TIME_UPDATE" = true ]; then
        end_time=$(date +%s)
        duration=$((end_time - start_time))
        hours=$((duration / 3600))
        minutes=$(( (duration % 3600) / 60 ))
        seconds=$((duration % 60))
        
        echo
        echo -e "${CYAN}───────────────────────────────────────────${NC}"
        echo -e "${GREEN}${BOLD}System update completed.${NC}"
        echo -ne "${BOLD}Duration: ${NC}"
        if [ $hours -gt 0 ]; then
            echo -e "${YELLOW}${hours}h ${minutes}m ${seconds}s${NC}"
        elif [ $minutes -gt 0 ]; then
            echo -e "${YELLOW}${minutes}m ${seconds}s${NC}"
        else
            echo -e "${YELLOW}${seconds}s${NC}"
        fi
        echo -e "${CYAN}───────────────────────────────────────────${NC}"
    else
        echo
        echo -e "${CYAN}───────────────────────────────────────────${NC}"    
        echo -e "${GREEN}${BOLD}         System update completed.${NC}"
        echo -e "${CYAN}───────────────────────────────────────────${NC}"
    fi
    echo
}

# Print header
echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│          SYSTEM UPDATE            │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"

# Check for distribution-specific updates
echo -e "\n${BOLD}Detected distribution:${NC} ${GREEN}$DISTRO${NC}"
ofc=$(count_updates)

# Format the update count with color based on number of updates
format_update_count() {
    local count=$1
    if [[ "$count" =~ ^[0-9]+$ ]]; then
        if [ "$count" -eq 0 ]; then
            echo -e "${GREEN}$count${NC}"
        elif [ "$count" -lt 10 ]; then
            echo -e "${YELLOW}$count${NC}"
        else
            echo -e "${RED}$count${NC}"
        fi
    else
        echo -e "${YELLOW}$count${NC}"
    fi
}

# Output the update status with proper formatting
echo -e "\n${BOLD}Available Updates:${NC}"
echo -e "${BOLD}[Official]${NC} $(format_update_count "$ofc")"

# Check for AUR updates (Arch-based only)
if [[ "$DISTRO" == "arch" || "$DISTRO" == "manjaro" || "$DISTRO" == "endeavouros" ]]; then
    if pkg_installed yay; then
        aur=$(yay -Qua 2>/dev/null | wc -l)
    elif pkg_installed paru; then
        aur=$(paru -Qua 2>/dev/null | wc -l)
    else
        aur="AUR helper not installed"
    fi
    echo -e "${BOLD}[AUR]     ${NC} $(format_update_count "$aur")"
fi

# Check for Flatpak updates
if pkg_installed flatpak || command -v flatpak &>/dev/null; then
    fpk=$(flatpak remote-ls --updates 2>/dev/null | wc -l)
    echo -e "${BOLD}[Flatpak] ${NC} $(format_update_count "$fpk")"
else
    echo -e "${BOLD}[Flatpak] ${NC} ${YELLOW}Not installed${NC}"
fi

# Draw separator line
echo -e "${CYAN}───────────────────────────────────────────${NC}"

# Ask for update confirmation
echo -e -n "${BOLD}Do you want to update the system? ${MID_BLUE}[Y/N]${NC}: ${NC}"
read answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
    update_system
else
    echo -e "${YELLOW}Update canceled.${NC}"
    echo
fi
