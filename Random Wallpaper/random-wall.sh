#!/bin/bash

# random-wall.sh
#
# Script to randomly change wallpaper
#
# Author: @fr0st-iwnl
#=================================================================
# Repository: https://github.com/fr0st-iwnl/sh-toolbox
#-----------------------------------------------------------------
# Issues: https://github.com/fr0st-iwnl/sh-toolbox/issues/
# Pull Requests: https://github.com/fr0st-iwnl/sh-toolbox/pulls
#-----------------------------------------------------------------

# Colors :)
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[1;34m"
MID_BLUE='\033[38;2;135;206;250m'
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
PURPLE="\033[0;35m"
RESET="\033[0m"

# Configuration file
CONFIG_DIR="$HOME/.config/random-wallpaper"
CONFIG_FILE="$CONFIG_DIR/config"

# Create config directory if not exists
mkdir -p "$CONFIG_DIR" 2>/dev/null

# Read saved configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Print styled messages
print_header() {
    echo -e "${BOLD}${GREEN}"
    echo "┌───────────────────────────────────┐"
    echo "│         RANDOM WALLPAPER          │"
    echo "└───────────────────────────────────┘"
}

print_header2() {
    echo -e "${BOLD}${YELLOW}"
    echo "┌───────────────────────────────────┐"
    echo "│           PATH SETTING            │"
    echo "└───────────────────────────────────┘"
}

print_header3() {
    echo -e "${BOLD}${BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│           HELP SETTING            │"
    echo "└───────────────────────────────────┘"
}

print_success() {
    echo -e "${GREEN}✓ $1${RESET}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${RESET}"
}

print_error() {
    echo -e "${RED}[✗] $1${RESET}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${RESET}"
}

# Function to save configuration
save_config() {
    echo "# Random Wallpaper Configuration" > "$CONFIG_FILE"
    echo "WALLPAPER_DIR=\"$WALLPAPER_DIR\"" >> "$CONFIG_FILE"
}

# Function to save the current wallpaper info
save_wallpaper_info() {
    echo "$WALLPAPER" > "$CONFIG_DIR/last_wallpaper"
}

# Function to display help message
show_help() {
    print_header3
    echo
    echo -e "${BOLD}${BLUE}Options:${RESET}"
    echo -e "  ${BOLD}-h, --help${RESET}     Show this help message"
    echo -e "  ${BOLD}-p, --path${RESET}     Specifies the path to wallpapers directory"
    echo -e "  ${BOLD}-s, --show${RESET}     Show the selected wallpaper in terminal (if supported)"
    echo
    exit 0
}

# Default configuration (if not saved in config file)
if [ -z "$WALLPAPER_DIR" ]; then
    WALLPAPER_DIR="$HOME/Pictures"
fi

# Get desktop environment (needed for several functions)
DESKTOP_ENV="$(echo $XDG_CURRENT_DESKTOP | tr '[:upper:]' '[:lower:]')"

SHOW_IMAGE=false
PATH_ARGS=()
PATH_CHANGED=false
SHOW_PATH_INFO=false  # New flag to track if we should show path info
PATH_PROVIDED=false   # Flag to track if a specific path was provided

# Function to get current wallpaper
get_current_wallpaper() {
    local current_wallpaper=""
    
    case "$DESKTOP_ENV" in
        *gnome*|*ubuntu*|*pantheon*)
            # Try both dark and light variants
            current_wallpaper=$(gsettings get org.gnome.desktop.background picture-uri | sed -e "s|^'file://||" -e "s|'$||")
            if [ -z "$current_wallpaper" ]; then
                current_wallpaper=$(gsettings get org.gnome.desktop.background picture-uri-dark | sed -e "s|^'file://||" -e "s|'$||")
            fi
            ;;
        *kde*|*plasma*)
            # Try to extract from Plasma config
            if [ -f "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" ]; then
                current_wallpaper=$(grep -A 10 "wallpaper=" "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc" | grep "Image=" | head -1 | sed -e "s|Image=file://||" -e "s|^Image=||")
            fi
            # Try alternative KDE config locations
            if [ -z "$current_wallpaper" ] && [ -d "$HOME/.kde4" ]; then
                current_wallpaper=$(find "$HOME/.kde4" -name "*plasma*" -type f -exec grep -l "wallpaper=" {} \; | xargs grep -l "Image=" | xargs grep "Image=" | head -1 | sed -e "s|Image=file://||" -e "s|^Image=||")
            fi
            ;;
        *xfce*)
            # Try to get from xfce4 settings
            for monitor in $(xfconf-query -c xfce4-desktop -l | grep -E "screen.*/last-image$"); do
                current_wallpaper=$(xfconf-query -c xfce4-desktop -p "$monitor" 2>/dev/null)
                if [ -n "$current_wallpaper" ]; then
                    break
                fi
            done
            ;;
        *i3*|*sway*|*bspwm*|*awesome*|*dwm*|*xmonad*)
            # Check common files where window managers might store this info
            if [ -f "$HOME/.fehbg" ]; then
                current_wallpaper=$(grep -o "'[^']*'" "$HOME/.fehbg" | head -1 | sed "s/'//g")
            elif [ -f "$HOME/.config/nitrogen/bg-saved.cfg" ]; then
                current_wallpaper=$(grep "file=" "$HOME/.config/nitrogen/bg-saved.cfg" | head -1 | sed "s|file=||")
            fi
            ;;
    esac
    
    # If still empty, try some more generic methods
    if [ -z "$current_wallpaper" ]; then
        # Try to find recently set wallpapers in the recent run
        recent_wallpaper_file="$CONFIG_DIR/last_wallpaper"
        if [ -f "$recent_wallpaper_file" ]; then
            current_wallpaper=$(cat "$recent_wallpaper_file")
        fi
        
        # Look in common generic locations
        if [ -z "$current_wallpaper" ] && [ -d "$HOME/.cache/wallpaper" ]; then
            current_wallpaper=$(find "$HOME/.cache/wallpaper" -type f -name "*.png" -o -name "*.jpg" | sort -n | tail -1)
        fi
    fi
    
    echo "$current_wallpaper"
}

# Function to show current wallpaper info
show_current_wallpaper() {
    local current_wallpaper=$(get_current_wallpaper)
    
    echo -e "${BOLD}${BLUE}╔════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${BLUE}║${RESET}        ${BOLD}${PURPLE}Current Wallpaper${RESET}                ${BOLD}${BLUE}║${RESET}"
    echo -e "${BOLD}${BLUE}╚════════════════════════════════════════════╝${RESET}"
    
    if [ -z "$current_wallpaper" ]; then
        print_info "Could not detect current wallpaper"
        print_info "Run script with a new wallpaper to initialize tracking"
    elif [ -f "$current_wallpaper" ]; then
        print_info "File: ${YELLOW}$(basename "$current_wallpaper")${RESET}"
        print_info "Path: $current_wallpaper"
        
        # Show image preview if requested
        if [ "$SHOW_IMAGE" = true ]; then
            echo -e "${BOLD}${BLUE}"
            echo "┌───────────────────────────────────┐"
            echo "│              PREVIEW              │"
            echo "└───────────────────────────────────┘"
            
            if command -v catimg >/dev/null 2>&1; then
                catimg -H 20 "$current_wallpaper"
            elif command -v timg >/dev/null 2>&1; then
                timg -g 60x16 "$current_wallpaper"
            elif command -v kitty >/dev/null 2>&1 && [ "$TERM" = "xterm-kitty" ]; then
                print_warning "Cannot display image in terminal."
                print_info "Install one of: catimg, timg, chafa, or img2sixel"
            elif command -v chafa >/dev/null 2>&1; then
                chafa -s 60x16 "$current_wallpaper"
            elif command -v img2sixel >/dev/null 2>&1; then
                img2sixel -w 300 "$current_wallpaper"
            else
                print_warning "Cannot display image in terminal."
                print_info "Install one of: catimg, timg, chafa, or img2sixel"
            fi
        fi
    else
        print_warning "Current wallpaper file not found: $current_wallpaper"
    fi
    echo
}

# Function to display image in terminal
display_image_preview() {
    local image_path="$1"
    
    if [ ! -f "$image_path" ]; then
        print_warning "Image file not found: $image_path"
        return 1
    fi
    
    echo -e "${BOLD}${BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│              PREVIEW              │"
    echo "└───────────────────────────────────┘"
    echo
    if command -v catimg >/dev/null 2>&1; then
        # catimg with height constraint (20 lines)
        catimg -H 20 "$image_path"
    elif command -v timg >/dev/null 2>&1; then
        # timg with width and height constraints
        timg -g 60x16 "$image_path"
    elif command -v kitty >/dev/null 2>&1 && [ "$TERM" = "xterm-kitty" ]; then
        # kitty with most basic command - maximum compatibility
        print_warning "Cannot display image in terminal."
        print_info "Install one of: catimg, timg, chafa, or img2sixel"
    elif command -v chafa >/dev/null 2>&1; then
        # chafa with size constraint
        chafa -s 60x16 "$image_path"
    elif command -v img2sixel >/dev/null 2>&1; then
        # img2sixel with width constraint
        img2sixel -w 300 "$image_path"
    else
        print_warning "Cannot display image in terminal."
        print_info "Install one of: catimg, timg, chafa, or img2sixel"
        return 1
    fi
    
    return 0
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            ;;
        -p|--path)
            SHOW_PATH_INFO=true
            shift
            # Check if there are no more arguments or next arg is a flag
            if [[ $# -eq 0 || "$1" =~ ^- ]]; then
                # We'll show the path info at the end, not here
                # This allows -p -s and -s -p to work the same way
                continue
            fi
            
            PATH_PROVIDED=true
            # Collect all arguments until the next option flag
            PATH_ARGS=()
            while [[ $# -gt 0 && ! "$1" =~ ^- ]]; do
                PATH_ARGS+=("$1")
                shift
            done
            # Join the path arguments back together
            if [[ ${#PATH_ARGS[@]} -gt 0 ]]; then
                WALLPAPER_DIR=$(printf "%s " "${PATH_ARGS[@]}")
                # Trim the trailing space
                WALLPAPER_DIR="${WALLPAPER_DIR% }"
                PATH_CHANGED=true
            fi
            continue
            ;;
        -s|--show)
            SHOW_IMAGE=true
            ;;
        -d|--default)
            print_warning "The -d/--default option is no longer needed."
            print_info "Paths set with -p/--path are now automatically saved."
            ;;
        *)
            # For backward compatibility, treat first non-option as path
            if [[ ! "$1" =~ ^- ]]; then
                # If this looks like a path without quotes
                WALLPAPER_DIR="$1"
                PATH_CHANGED=true
                PATH_PROVIDED=true
            else
                echo
                print_error "Unknown option:${RESET} $1"
                echo -e "Run ${MID_BLUE}random-wall --help${RESET} for usage information."
                echo
                exit 1
            fi
            ;;
    esac
    shift
done

# Save config if path was changed
if [ "$PATH_CHANGED" = true ]; then
    save_config
fi

# Show path info if requested with -p or --path
if [ "$SHOW_PATH_INFO" = true ]; then
    # First check if the provided path exists
    if [ "$PATH_PROVIDED" = true ] && [ ! -d "${WALLPAPER_DIR}" ]; then
        print_header2
        echo
        print_error "Wallpaper directory '${WALLPAPER_DIR}' does not exist."
        print_info "Please create the directory or specify a valid path."
        echo
        exit 1
    fi
    
    print_header2
    echo
    print_info "Current wallpaper directory: ${YELLOW}${WALLPAPER_DIR}${RESET}"
    
    # Show current wallpaper file inline
    current_wallpaper=$(get_current_wallpaper)
    if [ -n "$current_wallpaper" ] && [ -f "$current_wallpaper" ]; then
        print_info "Current wallpaper: ${YELLOW}$(basename "$current_wallpaper")${RESET}"
    fi
    
    print_info "To change directory, use: ${YELLOW}${BOLD}-p \"/path/to/wallpapers\"${RESET}"
    
    # Show saved message if path was changed
    if [ "$PATH_CHANGED" = true ]; then
        echo
        print_success "Saved directory preference"
    fi
    
    echo
    
    # Show image preview if requested and wallpaper exists
    if [ "$SHOW_IMAGE" = true ] && [ -n "$current_wallpaper" ] && [ -f "$current_wallpaper" ]; then
        display_image_preview "$current_wallpaper"
    fi
    
    exit 0
fi

print_header

print_info "Wallpaper directory: ${BOLD}${WALLPAPER_DIR}${RESET}"

# Use quotes around paths to handle spaces
if [ ! -d "${WALLPAPER_DIR}" ]; then
    print_error "Wallpaper directory '${WALLPAPER_DIR}' does not exist."
    print_info "Please specify a valid path with -p option."
    echo
    exit 1
fi

# Count wallpapers - use proper quoting for paths with spaces
print_info "Searching for wallpapers..."
# Use an array to properly handle filenames with spaces
WALLPAPERS=()
while IFS= read -r -d '' file; do
    WALLPAPERS+=("$file")
done < <(find "${WALLPAPER_DIR}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) -print0)
COUNT=${#WALLPAPERS[@]}

print_info "Found ${BOLD}${COUNT}${RESET}${CYAN} wallpapers${RESET}"

# Select random wallpaper - properly handle spaces in paths
if [ $COUNT -gt 0 ]; then
    RANDOM_INDEX=$((RANDOM % COUNT))
    WALLPAPER="${WALLPAPERS[$RANDOM_INDEX]}"
    
    print_info "Selected: ${BOLD}$(basename "${WALLPAPER}")${RESET}"
    print_info "Path: ${BOLD}${WALLPAPER}${RESET}"
else
    echo
    print_error "No wallpapers found."
    echo
    exit 1
fi

# Display image in terminal if requested
if [ "$SHOW_IMAGE" = true ]; then
    display_image_preview "${WALLPAPER}"
fi

# Set wallpaper based on desktop environment
case "$DESKTOP_ENV" in
    *gnome*|*ubuntu*|*pantheon*)
        gsettings set org.gnome.desktop.background picture-uri "file://${WALLPAPER}"
        gsettings set org.gnome.desktop.background picture-uri-dark "file://${WALLPAPER}"
        ;;
    *kde*|*plasma*)
        # Use proper escaping for paths with spaces in JavaScript
        ESCAPED_WALLPAPER=$(echo "${WALLPAPER}" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g')
        qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
            var allDesktops = desktops();
            for (i=0; i<allDesktops.length; i++) {
                d = allDesktops[i];
                d.wallpaperPlugin = 'org.kde.image';
                d.currentConfigGroup = Array('Wallpaper', 'org.kde.image', 'General');
                d.writeConfig('Image', 'file://${ESCAPED_WALLPAPER}');
            }
        "
        ;;
    *xfce*)
        for monitor in $(xfconf-query -c xfce4-desktop -l | grep -E "screen.*/last-image$"); do
            xfconf-query -c xfce4-desktop -p "$monitor" -s "${WALLPAPER}"
        done
        ;;
    *i3*|*sway*|*bspwm*|*awesome*|*dwm*|*xmonad*)
        # For most minimal window managers, we'll use feh
        feh --bg-fill "${WALLPAPER}"
        ;;
    *)
        # Try some common methods if desktop environment is not detected
        if command -v gsettings >/dev/null 2>&1; then
            gsettings set org.gnome.desktop.background picture-uri "file://${WALLPAPER}"
        elif command -v feh >/dev/null 2>&1; then
            feh --bg-fill "${WALLPAPER}"
        elif command -v nitrogen >/dev/null 2>&1; then
            nitrogen --set-zoom-fill "${WALLPAPER}"
        else
            print_error "Could not detect desktop environment. Please set the wallpaper manually."
            print_info "Wallpaper path: ${WALLPAPER}"
            exit 1
        fi
        ;;
esac

print_success "Wallpaper changed successfully!"
echo
save_wallpaper_info

# Remove the prompt at the end since we now always save when using -p
if [ "$PATH_CHANGED" = false ] && [ ! -f "$CONFIG_FILE" ]; then
    echo
    read -p "$(echo -e ${YELLOW}"Would you like to save this directory as default? (y/n): "${RESET})" SAVE_CHOICE
    if [[ "$SAVE_CHOICE" =~ ^[Yy]$ ]]; then
        save_config
    fi
fi
