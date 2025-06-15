#!/bin/bash

# keybind.sh
#
# A tool to manage keybindings using sxhkd.
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

# Configuration directory and files
CONFIG_DIR="$HOME/.config/sh-toolbox"
KEYBINDS_FILE="$CONFIG_DIR/keybinds.conf"
SXHKD_CONFIG="$HOME/.config/sxhkd/sxhkdrc"
SXHKD_CONFIG_BACKUP="$HOME/.config/sxhkd/sxhkdrc.backup"
SXHKD_TOOLBOX_SECTION="$CONFIG_DIR/sxhkd-section.conf"
SYSTEMD_SERVICE_FILE="$HOME/.config/systemd/user/sxhkd.service"

# Backup directory and file
BACKUP_DIR="$HOME/.local/share/bin/Keybindings Backup"
KEYBINDS_BACKUP="$BACKUP_DIR/keybinds.conf.backup"

# Global debug flag
DEBUG_MODE=false

# Function to show debug messages
debug_print() {
    if [ "$DEBUG_MODE" = true ]; then
        echo -e "${MAGENTA}[DEBUG] $1${NC}" >&2
    fi
}

# Ensure configuration directories exist
ensure_config_dirs() {
    mkdir -p "$CONFIG_DIR"
    mkdir -p "$(dirname "$SXHKD_CONFIG")"
    
    # Create keybinds file if it doesn't exist
    if [ ! -f "$KEYBINDS_FILE" ]; then
        touch "$KEYBINDS_FILE"
        # DO NOT load default keybindings here
        # This is to avoid auto-loading on first run after installation
        debug_print "Created empty keybinds file without loading defaults"
    fi
}

# Function to display help
show_keybind_help() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│      Keybinding Manager Help      │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"
    echo
    echo -e "${BOLD}${BLUE}Usage:${NC}"
    echo -e "  ${GREEN}keybind${NC} [command]"
    echo
    echo -e "${BOLD}${BLUE}Commands:${NC}"
    echo
    echo -e "${BOLD}${CYAN}● Keybinding Management:${NC}"
    echo -e "  ${GREEN}list${NC}                     - List all configured keybindings"
    echo -e "  ${GREEN}add${NC}                      - Add a new keybinding"
    echo -e "  ${GREEN}remove${NC}                   - Remove a keybinding"
    echo
    echo -e "${BOLD}${CYAN}● Configuration:${NC}"
    echo -e "  ${GREEN}load${NC}                     - Load sh-toolbox default keybindings"
    echo -e "  ${GREEN}reload${NC}                   - Reload sxhkd configuration"
    echo -e "  ${GREEN}startup${NC}                  - Configure sxhkd startup options"
    echo
    echo -e "${BOLD}${CYAN}● Backup & Restore:${NC}"
    echo -e "  ${GREEN}backup${NC}                   - Backup keybinding configuration"
    echo -e "  ${GREEN}restore${NC}                  - Restore keybinding backup"
    echo
    echo -e "${BOLD}${CYAN}● Help & Debug:${NC}"
    echo -e "  ${GREEN}help${NC}                     - Display this help information"
    echo -e "  ${GREEN}debug [command]${NC}          - Run any command in debug mode"
    echo
    echo -e "${YELLOW}[?] Note:${NC} Keybindings are managed through sxhkd. Make sure sxhkd is installed and running."
    echo
}

# Function to check if sxhkd is installed
check_sxhkd() {
    if ! command -v sxhkd &> /dev/null; then
        echo
        echo -e "${RED}[✗] sxhkd is not installed.${NC}" >&2
        echo -e "${YELLOW}Please install sxhkd to use the keybinding manager:${NC}"
        echo -e "  - For Arch Linux: ${GREEN}sudo pacman -S sxhkd${NC}"
        echo -e "  - For Debian/Ubuntu: ${GREEN}sudo apt install sxhkd${NC}"
        echo -e "  - For Fedora: ${GREEN}sudo dnf install sxhkd${NC}"
        echo
        return 1
    fi
    
    return 0
}

# Function to check if notify-send is installed
check_notify_send() {
    if ! command -v notify-send &> /dev/null; then
        echo -e "${YELLOW}[!] notify-send is not installed. Notifications will be disabled.${NC}" >&2
        echo -e "${YELLOW}To enable notifications, install libnotify:${NC}"
        echo -e "  - For Arch Linux: ${GREEN}sudo pacman -S libnotify${NC}"
        echo -e "  - For Debian/Ubuntu: ${GREEN}sudo apt install libnotify-bin${NC}"
        echo -e "  - For Fedora: ${GREEN}sudo dnf install libnotify${NC}"
        return 1
    fi
    
    return 0
}

# Function to list all keybindings
list_keybindings() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│        Configured Keybinds        │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"
    
    if [ ! -s "$KEYBINDS_FILE" ]; then
        echo -e "${YELLOW}No keybindings configured yet.${NC}"
        echo
        return
    fi
    
    echo -e "${BOLD}${BLUE}Your keybindings:${NC}"
    echo
    
    # Format and display keybindings from the file
    while IFS='|' read -r keys type command notify; do
        echo -e "${BOLD}${GREEN}$keys${NC}"
        echo -e "  Command: $command"
        
        if [ "$notify" = "true" ]; then
            echo -e "  Notify: ${GREEN}Enabled${NC}"
        else
            echo -e "  Notify: ${CYAN}Disabled${NC}"
        fi
        echo
    done < "$KEYBINDS_FILE"
}

# Helper function to sanitize key input
sanitize_keys() {
    local input="$1"
    
    # Replace common capitalized modifiers with lowercase
    local sanitized=$(echo "$input" | sed 's/Alt/alt/g' | sed 's/Ctrl/ctrl/g' | sed 's/Super/super/g' | sed 's/Shift/shift/g')
    
    echo "$sanitized"
}

# Function to add a new keybinding
add_keybinding() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│         Add New Keybinding        │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"
    
    # Get key combination
    echo -e "${BOLD}${BLUE}╭─ Enter the key combination ${NC}${YELLOW}(e.g., super + f)${NC}"
    echo -e "${BLUE}│ ${YELLOW}Note: The '${MID_BLUE}super${YELLOW}' key is usually the ${MID_BLUE}Windows key${YELLOW} on keyboards.${NC}"
    echo -e "${BLUE}│ "
    echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
    read -r keys_input
    
    # Sanitize keys
    keys=$(sanitize_keys "$keys_input")
    
    # Validate keys
    if [ -z "$keys" ]; then
        echo -e "${RED}[✗] Keybinding cannot be empty.${NC}"
        return 1
    fi
    
    # If keys were changed, notify the user
    if [ "$keys" != "$keys_input" ]; then
        echo
        echo -e "${YELLOW}[!] Your key combination was adjusted to: ${GREEN}$keys${NC}"
        echo -e "${YELLOW}    sxhkd requires lowercase modifiers.${NC}"
        echo
    fi
    
    # Check if keybinding already exists
    if grep -q "^$keys|" "$KEYBINDS_FILE"; then
        echo
        echo -e "${RED}[✗] This keybinding already exists.${NC}"
        echo
        return 1
    fi
    
    # Get command
    echo
    echo -e "${BOLD}${BLUE}╭─ Enter command to run${NC}"
    echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
    read -r command
    
    # Validate command
    if [ -z "$command" ]; then
        echo -e "${RED}[✗] Command cannot be empty.${NC}"
        return 1
    fi
    
    # Check if it's a simple command (single word)
    if [[ "$command" =~ ^[a-zA-Z0-9_\-]+$ ]]; then
        # Check if it exists as an application
        if ! command -v "$command" &> /dev/null; then
            echo
            echo -e "${YELLOW}[!] Warning: '$command' does not appear to be installed or in your PATH.${NC}"
            echo -e "${YELLOW}It may not work unless it's a built-in shell command or script.${NC}"
            echo
            echo -e "${BOLD}${CYAN}╭─ Continue anyway? [Y/n]:${NC}"
            echo -ne "${BOLD}${CYAN}╰─➤ ${NC}"
            read -r continue_anyway
            if [[ "$continue_anyway" =~ ^[Nn]$ ]]; then
                echo
                echo -e "${RED}[✗] Keybinding creation cancelled.${NC}"
                echo
                return 1
            fi
        else
            echo -e "${GREEN}[✓] Found '$command' in your PATH.${NC}"
        fi
    fi
    
    # Get notification preference
    echo
    echo -e "${BOLD}${BLUE}╭─ Enable notification when triggered? [y/N]${NC}"
    echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
    read -r notify_choice
    
    if [[ "$notify_choice" =~ ^[Yy]$ ]]; then
        notify="true"
    else
        notify="false"
    fi
    
    # For the keybinds file, we'll use "cmd" as the type for all commands
    type="cmd"
    
    # Save keybinding to file
    echo "$keys|$type|$command|$notify" >> "$KEYBINDS_FILE"
    
    # Generate sxhkd config
    generate_sxhkd_config
    
    # Reload sxhkd
    reload_sxhkd
    
    echo -e "${GREEN}[✓] Keybinding added successfully!${NC}"
    echo
}

# Function to remove a keybinding
remove_keybinding() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│         Remove Keybinding         │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"
    
    if [ ! -s "$KEYBINDS_FILE" ]; then
        echo -e "${YELLOW}[·] No keybindings configured yet.${NC}"
        echo
        return
    fi
    
    echo -e "${BOLD}${BLUE}Select keybinding to remove:${NC}"
    echo
    
    # Display keybindings with line numbers
    i=1
    while IFS='|' read -r keys type command notify; do
        echo -e "  ${BOLD}$i)${NC} ${GREEN}$keys${NC} - "
        echo -e "     Command: $command"
        i=$((i+1))
    done < "$KEYBINDS_FILE"
    
    total_keybinds=$((i-1))
    
    echo
    echo -e "${BOLD}${BLUE}╭─ Enter number(s) to remove, comma-separated ${NC}${YELLOW}(e.g., 1,3,5)${NC} or 'all' to remove all:${NC}"
    echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
    read -r choice
    
    if [[ "$choice" =~ ^[Qq]$ ]]; then
        echo
        echo -e "${RED}[✗] Operation cancelled.${NC}"
        echo
        return
    fi
    
    # Handle "all" option
    if [[ "$choice" == "all" ]]; then
        echo
        echo -e "${BOLD}${BLUE}╭─ This will remove ALL keybindings. Are you sure? [y/N]${NC}"
        echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
        read -r confirm
        
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo
            echo -e "${RED}[✗] Operation cancelled.${NC}"
            echo
            return
        fi
        
        # Clear the keybindings file
        > "$KEYBINDS_FILE"
        
        # Generate sxhkd config
        generate_sxhkd_config
        
        # Reload sxhkd
        reload_sxhkd
        
        echo -e "${GREEN}[✓] All keybindings removed successfully!${NC}"
        echo
        return
    fi
    
    # Handle multiple selections
    if [[ "$choice" == *","* ]]; then
        # Split by comma
        IFS=',' read -ra selections <<< "$choice"
        
        # Validate selections
        valid_selections=()
        for sel in "${selections[@]}"; do
            # Remove any spaces
            sel=$(echo "$sel" | tr -d ' ')
            
            if ! [[ "$sel" =~ ^[0-9]+$ ]]; then
                echo -e "${RED}[✗] Invalid selection: $sel. Skipping...${NC}"
                continue
            fi
            
            if [ "$sel" -lt 1 ] || [ "$sel" -gt "$total_keybinds" ]; then
                echo -e "${RED}[✗] Number out of range: $sel. Skipping...${NC}"
                continue
            fi
            
            valid_selections+=("$sel")
        done
        
        if [ ${#valid_selections[@]} -eq 0 ]; then
            echo -e "${RED}[✗] No valid selections provided.${NC}"
            return 1
        fi
        
        # Sort selections in descending order to avoid index shifting
        sorted_selections=($(for sel in "${valid_selections[@]}"; do echo "$sel"; done | sort -nr))
        
        # Create temporary file and remove each selected keybinding
        temp_file=$(mktemp)
        cp "$KEYBINDS_FILE" "$temp_file"
        
        for sel in "${sorted_selections[@]}"; do
            # Get the keybinding info for display
            keybind_info=$(sed -n "${sel}p" "$KEYBINDS_FILE")
            IFS='|' read -r kb_keys kb_type kb_command kb_notify <<< "$keybind_info"
            
            echo -e "${YELLOW}Removing keybinding: ${GREEN}$kb_keys${YELLOW} → ${GREEN}$kb_command${NC}"
            
            # Remove the line
            sed -i "${sel}d" "$temp_file"
        done
        
        # Apply changes
        mv "$temp_file" "$KEYBINDS_FILE"
        
        # Generate sxhkd config
        generate_sxhkd_config
        
        # Reload sxhkd
        reload_sxhkd
        
        echo -e "${GREEN}[✓] Selected keybindings removed successfully!${NC}"
        return
    fi
    
    # Handle single selection (original behavior)
    if ! [[ "$choice" =~ ^[0-9]+$ ]]; then
        echo
        echo -e "${RED}[✗] Invalid choice.${NC}"
        echo
        return 1
    fi
    
    if [ "$choice" -lt 1 ] || [ "$choice" -gt "$total_keybinds" ]; then
        echo
        echo -e "${RED}[✗] Number out of range.${NC}"
        echo
        return 1
    fi
    
    # Get the keybinding info for display
    keybind_info=$(sed -n "${choice}p" "$KEYBINDS_FILE")
    IFS='|' read -r kb_keys kb_type kb_command kb_notify <<< "$keybind_info"
    
    # Create temporary file and remove the selected keybinding
    temp_file=$(mktemp)
    sed "${choice}d" "$KEYBINDS_FILE" > "$temp_file"
    mv "$temp_file" "$KEYBINDS_FILE"
    
    # Generate sxhkd config
    generate_sxhkd_config
    
    # Reload sxhkd
    reload_sxhkd
    
    echo -e "${GREEN}[✓] Keybinding '${kb_keys}' for '${kb_command}' removed successfully!${NC}"
    echo
}

# Function to remove keybinding by name
remove_keybinding_by_name() {
    local keybind_name="$1"
    
    # Validate the keybinding name
    if [ -z "$keybind_name" ]; then
        echo -e "${RED}[✗] No keybinding name provided.${NC}" >&2
        return 1
    fi
    
    debug_print "Attempting to remove keybinding: '$keybind_name'"
    
    # Check if keybindings file exists and isn't empty
    if [ ! -s "$KEYBINDS_FILE" ]; then
        echo -e "${YELLOW}No keybindings configured yet.${NC}"
        return 1
    fi
    
    # Check if the input is a keybinding or an application name
    if [[ "$keybind_name" == *"+"* ]]; then
        # Input is a keybinding, sanitize it
        keybind_name=$(sanitize_keys "$keybind_name")
        debug_print "Sanitized keybinding: '$keybind_name'"
        
        # Check for exact match at the beginning of a line
        local line_number=$(grep -n "^$keybind_name|" "$KEYBINDS_FILE" | cut -d: -f1)
    else
        # Input is likely an application name or command
        debug_print "Searching for application/command: '$keybind_name'"
        # Search for it in the third field (application/command field)
        local line_number=$(awk -F'|' -v app="$keybind_name" '$3 == app {print NR; exit}' "$KEYBINDS_FILE")
    fi
    
    if [ -z "$line_number" ]; then
        echo -e "${RED}[✗] No keybinding found for '$keybind_name'.${NC}" >&2
        echo -e "${YELLOW}Use ${GREEN}keybind list${YELLOW} to see available keybindings.${NC}"
        return 1
    fi
    
    debug_print "Found keybinding at line $line_number"
    
    # Get the keybinding info for display
    local keybind_info=$(sed -n "${line_number}p" "$KEYBINDS_FILE")
    IFS='|' read -r kb_keys kb_type kb_command kb_notify <<< "$keybind_info"
    
    debug_print "Removing keybinding: '$kb_keys' for '$kb_command'"
    
    # Create temporary file and remove the selected keybinding
    temp_file=$(mktemp)
    sed "${line_number}d" "$KEYBINDS_FILE" > "$temp_file"
    mv "$temp_file" "$KEYBINDS_FILE"
    
    debug_print "Removed from keybinds.conf, now updating sxhkd config"
    
    # Generate sxhkd config
    generate_sxhkd_config
    
    # Reload sxhkd
    reload_sxhkd
    
    echo -e "${GREEN}[✓] Keybinding '${kb_keys}' for '${kb_command}' removed successfully!${NC}"
    return 0
}

# Function to generate sxhkd configuration
generate_sxhkd_config() {
    debug_print "Generating sxhkd configuration"
    
    # Create sh-toolbox section
    echo "# ======================================" > "$SXHKD_TOOLBOX_SECTION"
    echo "# sh-toolbox managed keybindings" >> "$SXHKD_TOOLBOX_SECTION"
    echo "# DO NOT EDIT THIS SECTION MANUALLY" >> "$SXHKD_TOOLBOX_SECTION"
    echo "# ======================================" >> "$SXHKD_TOOLBOX_SECTION"
    
    # Only add keybindings if they exist
    if [ -s "$KEYBINDS_FILE" ]; then
        debug_print "Adding keybindings from $KEYBINDS_FILE"
        echo >> "$SXHKD_TOOLBOX_SECTION"
        
        # Add keybindings to the section file
        while IFS='|' read -r keys type command notify; do
            # Ensure there's always a single space around plus signs for consistency
            formatted_keys=$(echo "$keys" | sed 's/\s*+\s*/\ + /g')
            debug_print "Adding keybinding: '$formatted_keys' for '$command'"
            
            echo "$formatted_keys" >> "$SXHKD_TOOLBOX_SECTION"
            
            # Check if the command is a script that likely has built-in notifications
            if [[ "$command" == *.sh ]] && [[ "$command" == *"toggle"* || "$command" == *"volume"* ]]; then
                # Script commands with built-in notifications don't need additional notifications
                echo "    $command" >> "$SXHKD_TOOLBOX_SECTION"
                debug_print "Using direct command for script that likely has built-in notifications: $command"
            elif [ "$notify" = "true" ] && command -v notify-send &> /dev/null; then
                # Command with notification
                echo "    notify-send \"Running command\" \"$command\" && $command" >> "$SXHKD_TOOLBOX_SECTION"
                debug_print "Adding notification to command: $command"
            else
                # Command without notification
                echo "    $command" >> "$SXHKD_TOOLBOX_SECTION"
                debug_print "Command without notification: $command"
            fi
            
            echo >> "$SXHKD_TOOLBOX_SECTION"
        done < "$KEYBINDS_FILE"
    else
        debug_print "No keybindings found in $KEYBINDS_FILE"
    fi
    
    # Check if sxhkdrc exists
    if [ -f "$SXHKD_CONFIG" ]; then
        debug_print "Found existing sxhkd config at $SXHKD_CONFIG"
        
        # Display current file for debugging
        if [ "$DEBUG_MODE" = true ]; then
            echo -e "${MAGENTA}Current sxhkdrc:${NC}" >&2
            cat "$SXHKD_CONFIG" >&2
            echo >&2
        fi
        
        # Make a backup
        cp "$SXHKD_CONFIG" "$SXHKD_CONFIG_BACKUP"
        debug_print "Created backup at $SXHKD_CONFIG_BACKUP"
        
        # The simplest approach: start with an empty config file
        > "$SXHKD_CONFIG"
        
        # Just append our section (with keybindings)
        cat "$SXHKD_TOOLBOX_SECTION" > "$SXHKD_CONFIG"
        debug_print "Created fresh sxhkd config with our managed section"
        
        # Display final file for debugging
        if [ "$DEBUG_MODE" = true ]; then
            echo -e "${MAGENTA}New sxhkdrc:${NC}" >&2
            cat "$SXHKD_CONFIG" >&2
            echo >&2
        fi
    else
        debug_print "No existing sxhkd config, creating new one"
        # If no config exists, create one with our section
        cat "$SXHKD_TOOLBOX_SECTION" > "$SXHKD_CONFIG"
    fi
    
    # Ensure proper permissions
    chmod 644 "$SXHKD_CONFIG"
    debug_print "Set permissions on $SXHKD_CONFIG"
}

# Function to reload sxhkd
reload_sxhkd() {
    echo
    # Check if sxhkd is running
    if pgrep -x sxhkd > /dev/null; then
        echo -e "${YELLOW}[>>] Reloading sxhkd configuration...${NC}"
        
        # Use the signal method - most reliable
        debug_print "Reloading sxhkd via signal"
        pkill -USR1 sxhkd
        
        # Verify sxhkd is still running after reload
        sleep 1
        if ! pgrep -x sxhkd > /dev/null; then
            echo -e "${RED}[✗] sxhkd stopped after reload attempt. Restarting...${NC}"
            sxhkd >/dev/null 2>&1 &
            disown
            
            sleep 1
            if pgrep -x sxhkd > /dev/null; then
                echo -e "${GREEN}[✓] sxhkd restarted successfully.${NC}"
            else
                echo -e "${RED}[✗] Failed to restart sxhkd. Please start it manually.${NC}"
            fi
        else
            debug_print "sxhkd still running after reload"
        fi
    else
        echo -e "${YELLOW}sxhkd is not running. Starting sxhkd...${NC}"
        
        # Direct start - most reliable method
        sxhkd >/dev/null 2>&1 &
        disown
        
        sleep 1
        if pgrep -x sxhkd > /dev/null; then
            echo -e "${GREEN}[✓] sxhkd started.${NC}"
        else
            echo -e "${RED}[✗] Failed to start sxhkd. Please check for errors:${NC}"
            echo -e "${YELLOW}Try running 'sxhkd -v' manually to see error messages.${NC}"
        fi
    fi
    echo
}

# Function to load default keybindings
load_default_keybindings() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│      Load Default Keybindings     │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"
    
    # Check if scripts exist - handle both direct call and environment variable
    local script_dir
    
    # Check if environment variable is set
    if [ -n "$KEYBIND_SCRIPTS_DIR" ]; then
        script_dir="$KEYBIND_SCRIPTS_DIR"
        debug_print "Using script directory from environment: $script_dir"
    else
        # Detect if we're running from the installed location or from the repo
        if [[ "$(realpath "$0")" == *"/.local/share/bin/"* ]]; then
            # We're running from the installed location, check common locations
            for dir in "$HOME/.local/share/bin/Keybindings" "$HOME/.local/share/sh-toolbox/Keybindings" "/usr/local/share/sh-toolbox/Keybindings"; do
                if [ -d "$dir" ]; then
                    script_dir="$dir"
                    debug_print "Found script directory at installed location: $script_dir"
                    break
                fi
            done
            
            if [ -z "$script_dir" ]; then
                # Fallback: use the directory from the script path
                script_dir="$(dirname "$(realpath "$0")")"
                debug_print "Falling back to script path: $script_dir"
            fi
        else
            # We're running from the repository
            script_dir="$(dirname "$(realpath "$0")")"
            debug_print "Using script directory from script path: $script_dir"
        fi
    fi
    
    # If we still don't have a valid script_dir, search some likely locations
    if [ ! -d "$script_dir" ] || [ ! -f "$script_dir/toggle_mic.sh" ]; then
        debug_print "Script directory not valid or missing scripts, searching for alternatives..."
        
        # Try to find scripts in the Keybindings directory relative to current directory
        if [ -d "./Keybindings" ] && [ -f "./Keybindings/toggle_mic.sh" ]; then
            script_dir="$(realpath "./Keybindings")"
            debug_print "Found scripts in ./Keybindings: $script_dir"
        # Try parent directory's Keybindings folder
        elif [ -d "../Keybindings" ] && [ -f "../Keybindings/toggle_mic.sh" ]; then
            script_dir="$(realpath "../Keybindings")"
            debug_print "Found scripts in ../Keybindings: $script_dir"
        fi
    fi
    
    debug_print "Final script directory: $script_dir"
    
    local toggle_mic="${script_dir}/toggle_mic.sh"
    local toggle_audio="${script_dir}/toggle_audio.sh"
    local volume_up="${script_dir}/volume_up.sh"
    local volume_down="${script_dir}/volume_down.sh"
    
    local missing_scripts=0
    
    # echo -e "${BOLD}${BLUE}Checking for scripts:${NC}"
    
    # Check each script
    # if [ -f "$toggle_mic" ]; then
       # echo -e "  ${GREEN}[✓] Found toggle_mic.sh${NC}"
    # else
        # echo -e "  ${RED}[✗] Missing toggle_mic.sh${NC}"
        # missing_scripts=$((missing_scripts+1))
    # fi
    
    # if [ -f "$toggle_audio" ]; then
        # echo -e "  ${GREEN}[✓] Found toggle_audio.sh${NC}"
    # else
        # echo -e "  ${RED}[✗] Missing toggle_audio.sh${NC}"
        # missing_scripts=$((missing_scripts+1))
    # fi
    
    # if [ -f "$volume_up" ]; then
        # echo -e "  ${GREEN}[✓] Found volume_up.sh${NC}"
    # else
        # echo -e "  ${RED}[✗] Missing volume_up.sh${NC}"
        # missing_scripts=$((missing_scripts+1))
    # fi
    
    # if [ -f "$volume_down" ]; then
       # echo -e "  ${GREEN}[✓] Found volume_down.sh${NC}"
    # else
        # echo -e "  ${RED}[✗] Missing volume_down.sh${NC}"
        # missing_scripts=$((missing_scripts+1))
    # fi
    
    # Check if any scripts are missing
    if [ $missing_scripts -gt 0 ]; then
        echo
        echo -e "${RED}[✗] Missing $missing_scripts script(s).${NC}"
        echo -e "${YELLOW}Please ensure all scripts are in the Keybindings directory.${NC}"
        return 1
    fi
    
    echo
    
    # Check if sxhkd is installed
    if ! command -v sxhkd &> /dev/null; then
        echo -e "${RED}[✗] sxhkd is not installed.${NC}"
        echo -e "${YELLOW}Please install sxhkd first:${NC}"
        echo -e "  - For Arch Linux: ${GREEN}sudo pacman -S sxhkd${NC}"
        echo -e "  - For Debian/Ubuntu: ${GREEN}sudo apt install sxhkd${NC}"
        echo -e "  - For Fedora: ${GREEN}sudo dnf install sxhkd${NC}"
        return 1
    fi
    
    # Check if there are existing keybindings
    local existing_keybinds=false
    if [ -s "$KEYBINDS_FILE" ]; then
        existing_keybinds=true
    fi
    
    # Check if sxhkdrc exists and contains content
    local existing_sxhkd=false
    if [ -f "$SXHKD_CONFIG" ] && [ -s "$SXHKD_CONFIG" ]; then
        existing_sxhkd=true
    fi
    
    # Warn the user
    if [ "$existing_keybinds" = true ]; then
        echo -e "${BOLD}${BLUE}Warning:${NC}"
        echo -e "${YELLOW}[!] You already have keybindings configured in sh-toolbox.${NC}"
        echo -e "${YELLOW}    These will be removed and replaced with the default configuration.${NC}"
        echo
    fi
    
    #if [ "$existing_sxhkd" = true ]; then
    #    echo -e "${YELLOW}[!] An existing sxhkd configuration file was found.${NC}"
    #    echo -e "${YELLOW}    Any keybindings not managed by sh-toolbox will be removed.${NC}"
    #fi
    
    echo -e "${BOLD}${BLUE}Default keybindings to be installed:${NC}"
    echo -e "  ${GREEN}Insert${NC}                    → Toggle microphone mute/unmute"
    echo -e "  ${GREEN}Pause${NC}                     → Toggle audio mute/unmute"
    echo -e "  ${GREEN}ctrl + shift + Up${NC}         → Increase volume"
    echo -e "  ${GREEN}ctrl + shift + Down${NC}       → Decrease volume"
    echo
    
    # Ask for confirmation
    echo -e "${BOLD}${BLUE}╭─Do you want to continue? [y/N]:${NC}"
    echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
    read -r answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo
        echo -e "${RED}[✗] Operation cancelled.${NC}"
        echo
        return 0
    fi
    
    echo
    
    # Clear existing keybindings
    > "$KEYBINDS_FILE"
    debug_print "Cleared existing keybindings"
    
    # Add new keybindings
    echo -e "${BOLD}${GREEN}[✓] Added default keybindings${NC}"
    
    # Toggle microphone - Enable notifications since the script has built-in notify-send
    echo "Insert|cmd|$toggle_mic|true" >> "$KEYBINDS_FILE"
    #echo -e "  ${GREEN}[✓] Added: Insert → Toggle microphone${NC}"
    
    # Toggle audio - Enable notifications since the script has built-in notify-send
    echo "Pause|cmd|$toggle_audio|true" >> "$KEYBINDS_FILE"
    #echo -e "  ${GREEN}[✓] Added: Pause → Toggle audio${NC}"
    
    # Volume up - Enable notifications since the script has built-in notify-send
    echo "ctrl + shift + Up|cmd|$volume_up|true" >> "$KEYBINDS_FILE"
    #echo -e "  ${GREEN}[✓] Added: ctrl + shift + Up → Volume up${NC}"
    
    # Volume down - Enable notifications since the script has built-in notify-send
    echo "ctrl + shift + Down|cmd|$volume_down|true" >> "$KEYBINDS_FILE"
    #echo -e "  ${GREEN}[✓] Added: ctrl + shift + Down → Volume down${NC}"
    
    # echo
    
    # Generate sxhkd config
    generate_sxhkd_config
    
    # Reload sxhkd
    reload_sxhkd
    
    echo -e "${GREEN}[✓] Default keybindings successfully loaded!${NC}"
    # echo -e "${YELLOW}[!] You may need to restart sxhkd or your window manager for some changes to take effect.${NC}"
    echo
    
    return 0
}

# Function to stop sxhkd completely
stop_sxhkd() {
    echo -e "${YELLOW}Stopping sxhkd...${NC}"
    
    # Try systemctl first if the service is active
    systemctl --user stop sxhkd.service 2>/dev/null
    
    # Then use pkill regardless
    pkill -x sxhkd 2>/dev/null
    
    # Wait a moment and check
    sleep 1
    if pgrep -x sxhkd > /dev/null; then
        echo -e "${YELLOW}Using force to stop sxhkd...${NC}"
        pkill -9 -x sxhkd 2>/dev/null
        sleep 1
        
        # Final check
        if pgrep -x sxhkd > /dev/null; then
            echo -e "${RED}[✗] Failed to stop sxhkd completely.${NC}"
            return 1
        fi
    fi
    
    echo -e "${GREEN}[✓] Sxhkd stopped.${NC}"
    return 0
}

# Function to configure sxhkd startup options
configure_startup() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│      Configure Sxhkd Startup      │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"
    
    # Create systemd user directory if it doesn't exist
    mkdir -p "$(dirname "$SYSTEMD_SERVICE_FILE")"
    
    # Check current startup status
    local sxhkd_enabled=false
    local sxhkd_active=false
    
    if systemctl --user is-enabled sxhkd.service &>/dev/null; then
        sxhkd_enabled=true
        echo -e "${BOLD}${GREEN}[✓] Sxhkd is currently configured to start automatically on login.${NC}"
    else
        echo -e "${BOLD}${YELLOW}[✗] Sxhkd is NOT currently configured to start automatically on login.${NC}"
    fi
    
    # Check if sxhkd is actually running
    if pgrep -x sxhkd > /dev/null; then
        sxhkd_active=true
        echo -e "${BOLD}${GREEN}[✓] Sxhkd is currently running.${NC}"
    else
        sxhkd_active=false
        echo -e "${BOLD}${YELLOW}[✗] Sxhkd is NOT currently running.${NC}"
    fi
    
    echo
    echo -e "${BOLD}${BLUE}Options:${NC}"
    echo -e "  ${GREEN}1${NC} - Enable sxhkd startup on login"
    echo -e "  ${GREEN}2${NC} - Disable sxhkd startup on login"
    echo -e "  ${GREEN}q${NC} - Return to main menu"
    echo
    
    echo -e "${BOLD}${BLUE}╭─ Choose an option [1/2/q]:${NC}"
    echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
    read -r option
    
    case "$option" in
        "1")
            # Create systemd service file if it doesn't exist
            if [ ! -f "$SYSTEMD_SERVICE_FILE" ]; then
                echo
                echo -e "${YELLOW}Creating systemd service file...${NC}"
                
                cat > "$SYSTEMD_SERVICE_FILE" << EOF
[Unit]
Description=Simple X Hotkey Daemon
Documentation=man:sxhkd(1)
After=graphical-session.target

[Service]
ExecStart=/usr/bin/sxhkd
ExecReload=/usr/bin/kill -SIGUSR1 \$MAINPID
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
EOF

                chmod 644 "$SYSTEMD_SERVICE_FILE"
            fi
            
            echo
            echo -e "${YELLOW}Enabling sxhkd service...${NC}"
            systemctl --user daemon-reload
            systemctl --user enable sxhkd.service
            
            # Try to start the service with error handling
            echo -e "${YELLOW}Starting sxhkd service...${NC}"
            
            # First stop any existing instances to avoid conflicts
            if pgrep -x sxhkd > /dev/null; then
                stop_sxhkd
            fi
            
            # Start the service
            systemctl --user start sxhkd.service
            
            # Check if it started
            sleep 1
            if pgrep -x sxhkd > /dev/null; then
                echo
                echo -e "${GREEN}[✓] Sxhkd service started successfully.${NC}"
            else
                echo -e "${RED}[✗] Failed to start sxhkd via systemd. Starting directly...${NC}"
                
                # Start sxhkd directly as fallback
                sxhkd >/dev/null 2>&1 &
                disown
                
                # Check if it started
                sleep 1
                if pgrep -x sxhkd > /dev/null; then
                    echo -e "${GREEN}[✓] Sxhkd started directly.${NC}"
                    echo -e "${YELLOW}Note: Systemd service might not be working correctly.${NC}"
                    echo -e "${YELLOW}      Try rebooting your system to verify startup works.${NC}"
                else
                    echo -e "${RED}[✗] Failed to start sxhkd. Please check for errors:${NC}"
                    echo -e "${YELLOW}Try running 'sxhkd -v' manually to see error messages.${NC}"
                fi
            fi
            
            echo
            echo -e "${GREEN}[✓] Sxhkd will now start automatically on login.${NC}"
            ;;
            
        "2")
            echo
            if [ -f "$SYSTEMD_SERVICE_FILE" ] && systemctl --user is-enabled sxhkd.service &>/dev/null; then
                echo -e "${YELLOW}Disabling sxhkd service...${NC}"
                systemctl --user disable sxhkd.service
                echo
                echo -e "${GREEN}[✓] Sxhkd will no longer start automatically on login.${NC}"
                
                # Ask if user wants to stop the current session
                if pgrep -x sxhkd > /dev/null; then
                    echo
                    echo -e "${BOLD}${BLUE}╭─ Do you want to stop the currently running sxhkd session? [y/N]:${NC}"
                    echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
                    read -r stop_option
                    
                    if [[ "$stop_option" =~ ^[Yy]$ ]]; then
                        stop_sxhkd
                    fi
                fi
            else
                # Even if service is not enabled, check if it's running and offer to stop it
                if pgrep -x sxhkd > /dev/null; then
                    echo -e "${YELLOW}Sxhkd is running but not configured for startup.${NC}"
                    echo
                    echo -e "${BOLD}${BLUE}╭─ Do you want to stop the currently running sxhkd session? [y/N]:${NC}"
                    echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
                    read -r stop_option
                    
                    if [[ "$stop_option" =~ ^[Yy]$ ]]; then
                        stop_sxhkd
                    fi
                else
                    echo -e "${YELLOW}Sxhkd is not configured for startup. No changes needed.${NC}"
                fi
            fi
            ;;
            
        "q"|"")
            ;;
            
        *)
            echo
            echo -e "${RED}[✗] Invalid option.${NC}"
            ;;
    esac
    
    echo
}

# Function to ensure sxhkd is running
ensure_sxhkd_running() {
    debug_print "ensure_sxhkd_running called"
    
    # Check if sxhkd is running
    if ! pgrep -x sxhkd > /dev/null; then
        debug_print "sxhkd is not running"
        
        # Don't auto-start in the startup menu
        if [[ "$1" == "no_autostart" ]]; then
            debug_print "Not auto-starting sxhkd because no_autostart flag is set"
            return 0
        fi
        
        debug_print "Attempting to start sxhkd"
        
        # Try direct start first as it's more reliable
        debug_print "Starting sxhkd directly"
        sxhkd >/dev/null 2>&1 &
        disown
        
        # Check if it started successfully
        sleep 1
        if pgrep -x sxhkd > /dev/null; then
            debug_print "sxhkd started successfully via direct launch"
            return 0
        else
            debug_print "Failed to start sxhkd directly"
            return 1
        fi
    else
        debug_print "sxhkd is already running"
        return 0
    fi
}

# Function to backup keybindings
backup_keybindings() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│       Backup Keybindings          │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"
    
    # Create backup directory if it doesn't exist
    mkdir -p "$BACKUP_DIR"
    
    # Check if there are any keybindings to backup
    if [ ! -s "$KEYBINDS_FILE" ]; then
        echo -e "${YELLOW}[!] No keybindings configured yet. Nothing to backup.${NC}"
        echo
        return 1
    fi
    
    # Copy the keybindings file
    cp "$KEYBINDS_FILE" "$KEYBINDS_BACKUP"
    
    # Check if backup was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Keybindings successfully backed up to:${NC}"
        echo -e "   ${CYAN}$KEYBINDS_BACKUP${NC}"
        echo
        echo -e "${YELLOW}[i] You can restore this backup after reinstallation with:${NC} keybind restore"
        echo
        return 0
    else
        echo
        echo -e "${RED}[✗] Failed to backup keybindings.${NC}"
        echo
        return 1
    fi
}

# Function to restore keybindings from backup
restore_keybindings() {
    echo -e "${BOLD}${MID_BLUE}"
    echo "┌───────────────────────────────────┐"
    echo "│       Restore Keybindings         │"
    echo "└───────────────────────────────────┘"
    echo -e "${NC}"
    
    # Check if backup exists
    if [ ! -f "$KEYBINDS_BACKUP" ]; then
        echo -e "${RED}[✗] No keybinding backup found at:${NC}"
        echo -e "   ${CYAN}$KEYBINDS_BACKUP${NC}"
        echo
        echo -e "${YELLOW}[i] You need to create a backup first with:${NC}"
        echo -e "   ${GREEN}keybind backup${NC}"
        
        # Check if there might be a backup at the old location
        local OLD_BACKUP_DIR="$HOME/.sh-toolbox-backup"
        local OLD_KEYBINDS_BACKUP="$OLD_BACKUP_DIR/keybinds.conf.backup"
        
        if [ -f "$OLD_KEYBINDS_BACKUP" ]; then
            echo
            echo -e "${YELLOW}[!] Found a backup at the old location:${NC}"
            echo -e "   ${CYAN}$OLD_KEYBINDS_BACKUP${NC}"
            echo
            echo -e "${BOLD}${BLUE}╭─ Would you like to migrate this backup to the new location? [Y/n]:${NC}"
            echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
            read -r migrate_choice
            
            if [[ ! "$migrate_choice" =~ ^[Nn]$ ]]; then
                # Create the new backup directory
                mkdir -p "$BACKUP_DIR"
                
                # Copy the old backup to the new location
                cp "$OLD_KEYBINDS_BACKUP" "$KEYBINDS_BACKUP"
                
                if [ $? -eq 0 ]; then
                    echo -e "${GREEN}[✓] Backup successfully migrated to:${NC}"
                    echo -e "   ${CYAN}$KEYBINDS_BACKUP${NC}"
                    echo
                    # Continue with the restore process
                else
                    echo
                    echo -e "${RED}[✗] Failed to migrate backup.${NC}"
                    echo
                    return 1
                fi
            else
                echo
                echo -e "${RED}[✗] Restore operation cancelled.${NC}"
                echo
                return 1
            fi
        else
            echo
            return 1
        fi
    fi
    
    # Check if backup is not empty
    if [ ! -s "$KEYBINDS_BACKUP" ]; then
        echo -e "${RED}[✗] Backup file exists but is empty.${NC}"
        echo
        return 1
    fi
    
    # Check if there are current keybindings
    if [ -s "$KEYBINDS_FILE" ]; then
        echo -e "${YELLOW}[!] You already have keybindings configured.${NC}"
        echo -e "${YELLOW}    These will be replaced with your backed up configuration.${NC}"
        echo
        echo -e "${BOLD}${BLUE}╭─ Continue with restore? [y/N]:${NC}"
        echo -ne "${BOLD}${BLUE}╰─➤ ${NC}"
        read -r confirm
        
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo
            echo -e "${RED}[✗] Restore operation cancelled.${NC}"
            echo
            return 1
        fi
    fi
    
    # Ensure the config directory exists
    ensure_config_dirs
    
    # Copy the backup to the keybinds file
    cp "$KEYBINDS_BACKUP" "$KEYBINDS_FILE"
    
    # Check if restore was successful
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}[✓] Keybindings successfully restored.${NC}"
        
        # Generate sxhkd config
        generate_sxhkd_config
        
        # Reload sxhkd
        reload_sxhkd
        
        echo
        return 0
    else
        echo -e "${RED}[✗] Failed to restore keybindings.${NC}"
        echo
        return 1
    fi
}

# Main function to handle keybinding commands
handle_keybind() {
    # Create config directories if they don't exist, but don't load anything yet
    ensure_config_dirs
    
    # Check for help flags first
    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        show_keybind_help
        return 0
    fi
    
    # Check for debug mode
    if [[ "$1" == "debug" ]]; then
        DEBUG_MODE=true
        shift
        echo -e "${MAGENTA}Debug mode enabled${NC}" >&2
    fi
    
    # Check if sxhkd is installed
    if ! check_sxhkd; then
        return 1
    fi
    
    # Check if notify-send is installed (just a warning)
    check_notify_send
    
    command="$1"
    
    # If no command is provided, show help
    if [ -z "$command" ]; then
        debug_print "No command provided, showing help"
        show_keybind_help
        return 0
    fi
    
    # Don't auto-start sxhkd for the startup command
    if [[ "$command" == "startup" ]]; then
        debug_print "Startup command detected, not auto-starting sxhkd"
        # Ensure sxhkd is running with no_autostart flag
        ensure_sxhkd_running "no_autostart"
    else
        # Ensure sxhkd is running
        ensure_sxhkd_running
    fi
    
    case "$command" in
        "list")
            list_keybindings
            ;;
        "add")
            add_keybinding
            ;;
        "remove")
            # Use only the interactive removal
            remove_keybinding
            ;;
        "load"|"default")
            load_default_keybindings
            ;;
        "reload")
            generate_sxhkd_config
            reload_sxhkd
            echo -e "${GREEN}[✓] sxhkd configuration reloaded.${NC}"
            echo
            ;;
        "backup")
            backup_keybindings
            ;;
        "restore")
            restore_keybindings
            ;;
        "startup")
            configure_startup
            ;;
        "help")
            show_keybind_help
            ;;
        *)
            echo
            echo -e "${RED}[✗] Unknown keybind command:${NC} $command" >&2
            echo -e "Run ${MID_BLUE}keybind --help${NC} for usage information."
            echo
            # Don't show help menu on error
            return 1
            ;;
    esac
    
    return 0
}

# Run the keybind handler with all arguments
handle_keybind "$@" 