#!/bin/bash

# remind-me.sh
#
# A script to set reminders with notifications and sound
#
# Author: @fr0st-iwnl
#=================================================================
# Repository: https://github.com/fr0st-iwnl/sh-toolbox
#-----------------------------------------------------------------
# Issues: https://github.com/fr0st-iwnl/sh-toolbox/issues/
# Pull Requests: https://github.com/fr0st-iwnl/sh-toolbox/pulls
#-----------------------------------------------------------------

# Colors :)
BOLD='\033[1m'
UNDERLINE='\033[4m'
RED='\033[1;31m'        # Brighter red (bold)
GREEN='\033[1;32m'      # Brighter green (bold)
YELLOW='\033[1;33m'     # Brighter yellow (bold)
BLUE='\033[1;34m'       # Brighter blue (bold)
PURPLE='\033[1;35m'     # Brighter magenta (bold)
CYAN='\033[1;36m'       # Brighter cyan (bold)
WHITE='\033[1;37m'      # Bright white (bold)
RESET='\033[0m'
BLINK='\033[5m'         # Blinking text

# Global flag for stopping beeps
STOP_BEEPS=0
BEEP_PID=""

# Define reminder directory
REMINDER_DIR="$HOME/.remind-me/reminders"

# Ensure reminder directory exists
ensure_reminder_dir() {
    if [ ! -d "$REMINDER_DIR" ]; then
        mkdir -p "$REMINDER_DIR"
    fi
}

# Define cleanup function to ensure no processes are left running
cleanup() {
    # Set flag to stop any beeping
    STOP_BEEPS=1
    
    # Kill the beep process if it exists
    if [ -n "$BEEP_PID" ] && ps -p $BEEP_PID > /dev/null 2>&1; then
        kill $BEEP_PID &>/dev/null
    fi
    
    # Find and kill any other related processes that might be causing sound
    pkill -f "speaker-test" &>/dev/null
    pkill -f "beep" &>/dev/null
    pkill -f "paplay /tmp/beep.wav" &>/dev/null
    pkill -f "aplay /tmp/beep.wav" &>/dev/null
    
    # Remove temporary files
    rm -f /tmp/beep.wav &>/dev/null
    
    exit 0
}

# Set up traps to ensure cleanup on exit
trap cleanup EXIT INT TERM HUP

# Function to print a centered, boxed header
# i dont like this so i'm not using it atm
print_header() {
    local text="$1"
    local term_width=$(tput cols)
    local text_length=${#text}
    local box_width=$((text_length + 4))
    local padding=$(( (term_width - box_width) / 2 ))
    
    # Print top border
    printf "%${padding}s" ""
    printf "${YELLOW}┌"
    printf "%0.s─" $(seq 1 $((box_width - 2)))
    printf "┐${RESET}\n"
    
    # Print text with side borders
    printf "%${padding}s" ""
    printf "${YELLOW}│ ${CYAN}${BOLD}%s${RESET}${YELLOW} │${RESET}\n" "$text"
    
    # Print bottom border
    printf "%${padding}s" ""
    printf "${YELLOW}└"
    printf "%0.s─" $(seq 1 $((box_width - 2)))
    printf "┘${RESET}\n"
}

# Function to print flashing reminder alert header
print_flashing_alert() {
    # For terminals that support it, use the blink attribute
    echo -e ${RED}${BOLD}${BLINK}
    echo
    echo "  ┌───────────────────────────────────┐"
    echo -e "  │          REMINDER ALERT!          │"
    echo "  └───────────────────────────────────┘"
    echo -e ${RESET}${WHITE}
}

# Function to attempt multiple beep methods (without terminal bell)
play_beep() {
    local sound_played=0
    
    # Method 1: Use system beep if available
    if command -v beep >/dev/null 2>&1; then
        beep -f 750 -l 100 >/dev/null 2>&1
        sound_played=1
    fi
    
    # Method 2: Use paplay if available (for Pulse Audio)
    if [ $sound_played -eq 0 ] && command -v paplay >/dev/null 2>&1; then
        # Create a temporary wav file with a beep if it doesn't exist
        if [ ! -f /tmp/beep.wav ]; then
            if command -v ffmpeg >/dev/null 2>&1; then
                ffmpeg -f lavfi -i "sine=frequency=800:duration=0.3" /tmp/beep.wav -y >/dev/null 2>&1
            fi
        fi
        
        # Play the beep.wav if it exists
        if [ -f /tmp/beep.wav ]; then
            paplay /tmp/beep.wav >/dev/null 2>&1
            sound_played=1
        fi
    fi
    
    # Method 3: Use speaker-test as fallback
    if [ $sound_played -eq 0 ] && command -v speaker-test >/dev/null 2>&1; then
        (speaker-test -t sine -f 800 -l 1 -p 100 >/dev/null 2>&1) & pid=$!
        sleep 0.3
        kill -9 $pid >/dev/null 2>&1
        sound_played=1
    fi
    
    # Method 4: Use aplay if available
    if [ $sound_played -eq 0 ] && command -v aplay >/dev/null 2>&1; then
        if [ -f /tmp/beep.wav ]; then
            aplay /tmp/beep.wav >/dev/null 2>&1
            sound_played=1
        fi
    fi
    
    # Method 5: Use mplayer if available
    if [ $sound_played -eq 0 ] && command -v mplayer >/dev/null 2>&1; then
        if [ -f /tmp/beep.wav ]; then
            mplayer /tmp/beep.wav -really-quiet >/dev/null 2>&1
            sound_played=1
        fi
    fi
    
    # Method 6: Visual flash if no sound methods available
    if [ $sound_played -eq 0 ]; then
        # We'll rely on the flashing text in the alert header
        sleep 0.3
    fi
    
    # Brief pause between beeps
    sleep 0.3
}

# Function to play continuous beeps in the background until stopped
continuous_beep() {
    # Reset the stop flag
    STOP_BEEPS=0
    
    # Start continuous beeping in the background
    while [ $STOP_BEEPS -eq 0 ]; do
        play_beep
        sleep 0.7  # Longer pause between repeated alerts
    done
}

# Function to wait for key press and stop beeps
wait_for_keypress() {
    # Define a trap to handle Ctrl+C gracefully
    trap 'STOP_BEEPS=1; echo -e "\n  ${RED}Reminder dismissed${RESET}"; cleanup' INT
    
    # Start reading in the background
    read -r
    
    # Stop the beeps
    STOP_BEEPS=1
}

# Function to parse complex time formats (1h 5m 10s)
parse_complex_time() {
    local time_str="$*"  # All arguments combined
    local total_seconds=0
    local hours=0
    local minutes=0
    local seconds=0
    local duration_str=""
    
    # Extract hours if present
    if [[ "$time_str" =~ ([0-9]+)h ]]; then
        hours=${BASH_REMATCH[1]}
        total_seconds=$((total_seconds + hours * 3600))
        duration_str+="${hours}h "
    fi
    
    # Extract minutes if present
    if [[ "$time_str" =~ ([0-9]+)m ]]; then
        minutes=${BASH_REMATCH[1]}
        total_seconds=$((total_seconds + minutes * 60))
        duration_str+="${minutes}m "
    fi
    
    # Extract seconds if present
    if [[ "$time_str" =~ ([0-9]+)s ]]; then
        seconds=${BASH_REMATCH[1]}
        total_seconds=$((total_seconds + seconds))
        duration_str+="${seconds}s "
    fi
    
    if [ $total_seconds -eq 0 ]; then
        # No valid time units found
        return 1
    fi
    
    echo "$total_seconds $duration_str"
    return 0
}

# Function to validate time format
validate_time() {
    local time_str="$1"
    
    # Check for help flags or other switches that start with -
    if [[ "$time_str" == -* ]]; then
        show_error "Invalid time format: '$time_str'"
    fi
    
    # Check if it's a valid HH:MM or HH:MM:SS format
    if [[ "$time_str" =~ ^([0-9]|[0-1][0-9]|2[0-3]):([0-5][0-9])(:[0-5][0-9])?$ ]]; then
        return 0
    fi
    
    # Check if it's a valid complex time format (1h 5m 10s)
    if parse_complex_time "$time_str" > /dev/null; then
        return 0
    fi
    
    # Check if it's a valid simple duration (30m, 1h, etc.)
    if [[ "$time_str" =~ ^[0-9]+[smhd]$ ]]; then
        # Extract the unit
        local unit="${time_str: -1}"
        # Only allow valid units
        if [[ "$unit" =~ ^[smhd]$ ]]; then
            return 0
        fi
    fi
    
    # If none of the above, it's invalid
    show_error "Invalid time format: '$time_str'"
}

# Function to calculate wait time from time specification
calculate_wait_time() {
    local TIME_SPEC="$*"
    local WAIT_SECONDS=0
    local DISPLAY_TIME=""
    local IS_TOMORROW=0
    local DESCRIPTION=""
    
    # Check if time is in HH:MM or HH:MM:SS format
    if [[ "$TIME_SPEC" =~ ^([0-9]|[0-1][0-9]|2[0-3]):([0-5][0-9])(:[0-5][0-9])?$ ]]; then
        # It's a specific time format (HH:MM or HH:MM:SS)
        TARGET_HOUR=$(echo "$TIME_SPEC" | cut -d: -f1)
        TARGET_MIN=$(echo "$TIME_SPEC" | cut -d: -f2)
        
        # Check if seconds were specified
        if [[ "$TIME_SPEC" =~ .*:.+:.+ ]]; then
            TARGET_SEC=$(echo "$TIME_SPEC" | cut -d: -f3)
        else
            TARGET_SEC=0
        fi
        
        # Remove leading zeros to prevent base interpretation issues
        TARGET_HOUR=$(echo "$TARGET_HOUR" | sed 's/^0*//')
        TARGET_MIN=$(echo "$TARGET_MIN" | sed 's/^0*//')
        TARGET_SEC=$(echo "$TARGET_SEC" | sed 's/^0*//')
        
        # If values are empty after removing zeros, set to 0
        [ -z "$TARGET_HOUR" ] && TARGET_HOUR=0
        [ -z "$TARGET_MIN" ] && TARGET_MIN=0
        [ -z "$TARGET_SEC" ] && TARGET_SEC=0
        
        # Get current time
        CURRENT_HOUR=$(date +%-H)  # Use %-H to avoid leading zeros
        CURRENT_MIN=$(date +%-M)   # Use %-M to avoid leading zeros
        CURRENT_SEC=$(date +%-S)   # Use %-S to avoid leading zeros
        
        # Calculate seconds until the target time
        CURRENT_TOTAL_SECONDS=$((CURRENT_HOUR * 3600 + CURRENT_MIN * 60 + CURRENT_SEC))
        TARGET_TOTAL_SECONDS=$((TARGET_HOUR * 3600 + TARGET_MIN * 60 + TARGET_SEC))
        
        # If target time is earlier today, assume it's for tomorrow
        if [ $TARGET_TOTAL_SECONDS -le $CURRENT_TOTAL_SECONDS ]; then
            TARGET_TOTAL_SECONDS=$((TARGET_TOTAL_SECONDS + 86400))  # Add 24 hours
            WAIT_SECONDS=$((TARGET_TOTAL_SECONDS - CURRENT_TOTAL_SECONDS))
            IS_TOMORROW=1
            
            # Format display time without showing seconds if they weren't specified
            if [[ "$TIME_SPEC" =~ .*:.+:.+ ]]; then
                DISPLAY_TIME="$TIME_SPEC"
            else
                DISPLAY_TIME="$TIME_SPEC:00"
            fi
            
            DESCRIPTION="Clock time (tomorrow)"
        else
            WAIT_SECONDS=$((TARGET_TOTAL_SECONDS - CURRENT_TOTAL_SECONDS))
            
            # Format display time without showing seconds if they weren't specified
            if [[ "$TIME_SPEC" =~ .*:.+:.+ ]]; then
                DISPLAY_TIME="$TIME_SPEC"
            else
                DISPLAY_TIME="$TIME_SPEC:00"
            fi
            
            DESCRIPTION="Clock time (today)"
        fi
    else
        # Check if it's a complex time format with multiple units (1h 5m 10s)
        COMPLEX_TIME_RESULT=$(parse_complex_time $TIME_SPEC)
        
        if [ $? -eq 0 ]; then
            # It's a complex time format
            WAIT_SECONDS=$(echo "$COMPLEX_TIME_RESULT" | cut -d' ' -f1)
            DURATION_STR=$(echo "$COMPLEX_TIME_RESULT" | cut -d' ' -f2-)
            DISPLAY_TIME="$DURATION_STR"
            DESCRIPTION="Single duration"
        else
            # Try as a simple duration format (e.g., 30m)
            TIME="$TIME_SPEC"
            VALUE=$(echo "$TIME" | sed 's/[^0-9]*//g')
            UNIT=$(echo "$TIME" | sed 's/[0-9]*//g')
            
            case "$UNIT" in
                s) 
                    WAIT_SECONDS=$VALUE
                    UNIT_FULL="seconds"
                    ;;
                m) 
                    WAIT_SECONDS=$((VALUE * 60))
                    UNIT_FULL="minutes" 
                    ;;
                h) 
                    WAIT_SECONDS=$((VALUE * 3600))
                    UNIT_FULL="hours" 
                    ;;
                d) 
                    WAIT_SECONDS=$((VALUE * 86400))
                    UNIT_FULL="days" 
                    ;;
                *)
                    # Don't echo directly, return error code instead
                    return 1
                    ;;
            esac
            
            DISPLAY_TIME="$VALUE $UNIT_FULL"
            DESCRIPTION="Simple duration"
        fi
    fi
    
    # Return the calculated results
    echo "$WAIT_SECONDS|$DISPLAY_TIME|$DESCRIPTION|$IS_TOMORROW"
}

# Function to show error and exit
show_error() {
    echo
    echo -e "${RED}${BOLD}ERROR:${RESET} $1"
    echo
    echo -e "Use either ${GREEN}HH:MM[:SS]${RESET}, a duration (e.g., ${GREEN}30m${RESET}), or complex format (e.g., ${GREEN}1h 5m 10s${RESET})."
    echo -e "Run ${GREEN}remind-me --help${RESET} for more information."
    echo
    exit 1
}

# Generate a unique ID for reminders
generate_id() {
    echo $((RANDOM + 1000))
}

# Save reminder details to file
save_reminder() {
    local id="$1"
    local message="$2"
    local wait_seconds="$3"
    local display_time="$4"
    local description="$5"
    local pid="$6"
    
    # Calculate trigger time
    local trigger_time=$(date -d "+$wait_seconds seconds" "+%Y-%m-%d %H:%M:%S")
    
    # Ensure reminder directory exists
    ensure_reminder_dir
    
    # Create reminder file - NOTE: Variables must be properly quoted
    cat > "$REMINDER_DIR/$id.reminder" << EOF
ID="$id"
PID="$pid"
MESSAGE="$message"
WAIT_SECONDS="$wait_seconds"
DISPLAY_TIME="$display_time"
DESCRIPTION="$description"
TRIGGER_TIME="$trigger_time"
CREATED_AT="$(date "+%Y-%m-%d %H:%M:%S")"
EOF
}

# Remove reminder file
remove_reminder() {
    local id="$1"
    if [ -f "$REMINDER_DIR/$id.reminder" ]; then
        rm "$REMINDER_DIR/$id.reminder"
    fi
}

# List all active reminders
list_reminders() {
    ensure_reminder_dir
    
    if [ ! "$(ls -A $REMINDER_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}No active reminders.${RESET}"
        return
    fi
    
    # Print header
    printf "${BOLD}%-6s | %-30s | %-20s | %-15s${RESET}\n" "ID" "MESSAGE" "TRIGGERS AT" "TYPE"
    printf "%-6s-|-%-30s-|-%-20s-|-%-15s\n" "------" "------------------------------" "--------------------" "---------------"
    
    # For each reminder file
    for reminder in "$REMINDER_DIR"/*.reminder; do
        if [ -f "$reminder" ]; then
            # Source the file to get variables - use a subshell to avoid polluting the current environment
            (
                source "$reminder"
                
                # Check if the process is still running
                if ! ps -p "$PID" > /dev/null 2>&1; then
                    # Process no longer exists, remove the reminder
                    rm "$reminder"
                    return
                fi
                
                # Format the trigger time for display
                FORMATTED_TIME=$(date -d "$TRIGGER_TIME" "+%a %b %-d, %H:%M")
                
                # Print reminder details
                printf "${CYAN}%-6s${RESET} | ${GREEN}%-30s${RESET} | ${YELLOW}%-20s${RESET} | ${PURPLE}%-15s${RESET}\n" \
                    "$ID" "${MESSAGE:0:30}" "$FORMATTED_TIME" "$DESCRIPTION"
            )
        fi
    done
}

# Stop a specific reminder by ID
stop_reminder() {
    local id="$1"
    
    if [ -z "$id" ]; then
        echo -e "${RED}${BOLD}ERROR:${RESET} Missing reminder ID."
        echo -e "Usage: remind-me stop <id>"
        return 1
    fi
    
    if [ ! -f "$REMINDER_DIR/$id.reminder" ]; then
        echo -e "${RED}${BOLD}ERROR:${RESET} Reminder ID $id not found."
        return 1
    fi
    
    # Source the reminder file to get PID and message - use a subshell
    local PID MESSAGE
    eval $(grep -E '^(PID|MESSAGE)=' "$REMINDER_DIR/$id.reminder")
    
    # Kill the process if it's still running
    if ps -p "$PID" > /dev/null 2>&1; then
        kill "$PID"
        echo -e "${GREEN}Reminder ${YELLOW}\"$MESSAGE\"${GREEN} cancelled.${RESET}"
    else
        echo -e "${YELLOW}Note: Reminder process was not running.${RESET}"
    fi
    
    # Remove the reminder file
    rm "$REMINDER_DIR/$id.reminder"
    return 0
}

# Stop all active reminders
stop_all_reminders() {
    ensure_reminder_dir
    
    if [ ! "$(ls -A $REMINDER_DIR 2>/dev/null)" ]; then
        echo -e "${YELLOW}No active reminders to stop.${RESET}"
        return
    fi
    
    local count=0
    
    # For each reminder file
    for reminder in "$REMINDER_DIR"/*.reminder; do
        if [ -f "$reminder" ]; then
            # Source the file to get variables - use a subshell
            local PID
            eval $(grep '^PID=' "$reminder")
            
            # Kill the process if it's still running
            if ps -p "$PID" > /dev/null 2>&1; then
                kill "$PID"
                count=$((count + 1))
            fi
            
            # Remove the reminder file
            rm "$reminder"
        fi
    done
    
    echo -e "${GREEN}Stopped ${YELLOW}$count${GREEN} active reminders.${RESET}"
}

# Run the reminder in the background
run_background_reminder() {
    # Generate a unique ID for this reminder
    local id=$(generate_id)
    local message="$1"
    shift
    
    # Calculate wait time
    local time_spec="$*"
    
    # Validate the time specification first
    validate_time "$time_spec"
    
    local wait_result=$(calculate_wait_time "$time_spec")
    
    # Check if we got valid results
    if [ -z "$wait_result" ]; then
        echo -e "${RED}${BOLD}ERROR:${RESET} Failed to calculate wait time."
        exit 1
    fi
    
    # Parse the results
    IFS='|' read -r WAIT_SECONDS DISPLAY_TIME DESCRIPTION IS_TOMORROW <<< "$wait_result"
    
    # Additional validation
    if [ -z "$WAIT_SECONDS" ] || [ "$WAIT_SECONDS" -le 0 ]; then
        echo -e "${RED}${BOLD}ERROR:${RESET} Invalid wait time calculated."
        exit 1
    fi
    
    # Calculate trigger time
    local trigger_time=$(date -d "+$WAIT_SECONDS seconds" "+%a %b %-d, %Y @ %I:%M:%S %p")
    
    # Create the background process
    {
        # Sleep until the reminder is due
        sleep $WAIT_SECONDS
        
        # Show a notification
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "Reminder" "$message" --icon=appointment-soon --urgency=critical
        fi
        
        # Add sound (continue making noise until user intervenes)
        # Create a temp file to signal when to stop beeping
        local stop_file="/tmp/remind-me-$id-stop"
        touch "$stop_file"
        
        # Initialize counter
        local i=0
        
        # Keep beeping until the stop file is removed
        while [ -f "$stop_file" ]; do
            play_beep
            sleep 0.5
            
            # We'll stop after 30 beeps (about 15 seconds) if no one dismisses
            i=$((i+1))
            if [ $i -gt 30 ]; then
                rm -f "$stop_file"
            fi
        done
        
        # Remove the reminder file
        remove_reminder $id
    } &
    
    # Get the PID of the background process
    local bg_pid=$!
    
    # Save reminder details
    save_reminder "$id" "$message" "$WAIT_SECONDS" "$DISPLAY_TIME" "$DESCRIPTION" "$bg_pid"
    
    # Display confirmation message
    echo -e "${GREEN}${BOLD}Reminder #${id} set:${RESET}"
    echo -e "  ${WHITE}${BOLD}Message:${RESET}  ${GREEN}$message${RESET}"
    echo -e "  ${WHITE}${BOLD}Type:${RESET}     ${CYAN}$DESCRIPTION${RESET}"
    echo -e "  ${WHITE}${BOLD}Wait:${RESET}     ${YELLOW}$DISPLAY_TIME${RESET}"
    echo -e "  ${WHITE}${BOLD}Triggers:${RESET} ${PURPLE}$trigger_time${RESET}"
    echo
    echo -e "${CYAN}Running in background. Use '${WHITE}remind-me list${CYAN}' to see active reminders.${RESET}"
}

# The main function for setting a normal (foreground) reminder
set_reminder() {
    local MESSAGE="$1"
    shift
    local TIME_SPEC="$*"
    
    # Validate the time specification
    validate_time "$TIME_SPEC"

    # Clear screen for better visual
    clear
    # Show a compact, red background alert
    echo -en "${WHITE}${BOLD}${GREEN}"
    echo
    echo "  ┌───────────────────────────────────┐"
    echo "  │         SETTING UP REMINDER       │"
    echo "  └───────────────────────────────────┘"
    echo
    
    # Calculate wait time
    local wait_result=$(calculate_wait_time "$TIME_SPEC")
    
    # Parse the results
    IFS='|' read -r WAIT_SECONDS DISPLAY_TIME DESCRIPTION IS_TOMORROW <<< "$wait_result"
    
    # Display reminder information
    echo -e "  ${WHITE}${BOLD}Type:${RESET}     ${CYAN}$DESCRIPTION${RESET}"
    echo -e "  ${WHITE}${BOLD}Wait:${RESET}     ${YELLOW}$DISPLAY_TIME${RESET}"
    echo -e "  ${WHITE}${BOLD}Message:${RESET}  ${GREEN}$MESSAGE${RESET}"
    
    # Display trigger time in a consistent format
    TRIGGER_TIME=$(date -d "+$WAIT_SECONDS seconds" "+%a %b %-d, %Y @ %I:%M:%S %p")
    echo -e "  ${WHITE}${BOLD}Triggers:${RESET} ${PURPLE}$TRIGGER_TIME${RESET}"
    
    # Display countdown if wait time is less than a day
    if [ $WAIT_SECONDS -lt 86400 ]; then
        HOURS=$((WAIT_SECONDS / 3600))
        MINUTES=$(((WAIT_SECONDS % 3600) / 60))
        SECONDS=$((WAIT_SECONDS % 60))
        echo -e "  ${WHITE}${BOLD}Countdown:${RESET} ${YELLOW}${HOURS}h ${MINUTES}m ${SECONDS}s${RESET}"
    fi
    
    echo
    echo -e "  ${CYAN}Reminder running... (Press Ctrl+C to cancel)${RESET}"
    
    # Sleep until the specified time
    sleep $WAIT_SECONDS
    
    # Clear screen for the reminder alert
    clear
    
    # Show a compact, flashing alert
    echo -en "${WHITE}${BOLD}${RED}"
    print_flashing_alert
    
    # Show notification if notify-send is available
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "Reminder" "$MESSAGE" --icon=appointment-soon --urgency=critical
    fi
    
    # Output to terminal with color and formatting
    echo -e "  ${WHITE}${BOLD}Message:${RESET} ${GREEN}${BOLD}$MESSAGE${RESET}"
    echo -e "  ${WHITE}${BOLD}Time:${RESET}    ${YELLOW}$(date "+%I:%M:%S %p")${RESET}"
    echo
    
    # Add a divider
    echo -e "  ${YELLOW}────────────────────────────────────${RESET}"
    echo -e "  ${CYAN}(Press Enter to dismiss)${RESET}"
    
    # Start continuous beeping in background
    continuous_beep &
    BEEP_PID=$!
    
    # Wait for user to press Enter
    wait_for_keypress
    
    # Trigger cleanup to ensure everything is properly terminated
    cleanup
}

# Show help message
show_help() {
    clear
    echo -en "${WHITE}${BOLD}${GREEN}"
    echo
    echo "  ┌───────────────────────────────────┐"
    echo "  │           REMIND-ME HELP          │"
    echo "  └───────────────────────────────────┘"
    echo
    
    echo -e "${WHITE}${BOLD}USAGE:${RESET}"
    echo -e "  ${GREEN}remind-me ${YELLOW}\"Message\" ${CYAN}<time>${RESET}"
    echo -e "  ${GREEN}remind-me ${CYAN}-b ${YELLOW}\"Message\" ${CYAN}<time>${RESET}"
    echo -e "  ${GREEN}remind-me ${CYAN}list${RESET}"
    echo -e "  ${GREEN}remind-me ${CYAN}stop ${YELLOW}<id>${RESET}"
    echo -e "  ${GREEN}remind-me ${CYAN}stop-all${RESET}"
    echo
    echo -e "${WHITE}${BOLD}TIME FORMATS:${RESET}"
    echo -e "  ${CYAN}• Single duration:${RESET} ${GREEN}30s${RESET}, ${GREEN}10m${RESET}, ${GREEN}2h${RESET}, ${GREEN}1d${RESET}"
    echo -e "  ${CYAN}• Multiple units:${RESET} ${GREEN}1h 30m${RESET}, ${GREEN}2h 15m 30s${RESET}"
    echo -e "  ${CYAN}• Clock time:${RESET} ${GREEN}9:00${RESET}, ${GREEN}14:30${RESET}, ${GREEN}23:45:30${RESET} (24-hour format)"
    echo
    echo -e "${WHITE}${BOLD}COMMANDS:${RESET}"
    echo -e "  ${GREEN}• -h, --help${RESET}    Show this help message"
    echo -e "  ${GREEN}• -b, --background${RESET}: Set a reminder that runs in the background"
    echo -e "  ${GREEN}• list${RESET}:        List all active background reminders"
    echo -e "  ${GREEN}• stop <id>${RESET}:    Stop a specific background reminder"
    echo -e "  ${GREEN}• stop-all${RESET}:     Stop all background reminders"
    echo
    echo -e "${WHITE}${BOLD}EXAMPLES:${RESET}"
    echo -e "  ${GREEN}remind-me ${YELLOW}\"Check email\" ${CYAN}10m${RESET}"
    echo -e "  ${GREEN}remind-me ${CYAN}-b ${YELLOW}\"Team meeting\" ${CYAN}2h 30m${RESET}"
    echo -e "  ${GREEN}remind-me ${YELLOW}\"Take medication\" ${CYAN}8:00${RESET}"
    echo -e "  ${GREEN}remind-me ${CYAN}list${RESET}"
    echo
    
    # Exit cleanly
    exit 0
}

# Main program logic - process command line arguments
main() {
    # If no arguments provided, show help
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi
    
    # Check commands
    case "$1" in
        "list")
            list_reminders
            ;;
        "stop")
            if [ -z "$2" ]; then
                echo
                echo -e "${RED}${BOLD}ERROR:${RESET} Missing reminder ID."
                echo -e "Usage: remind-me stop <id>"
                echo
                exit 1
            fi
            stop_reminder "$2"
            ;;
        "stop-all")
            stop_all_reminders
            ;;
        "-b"|"--background")
            if [ $# -lt 3 ]; then
                echo
                echo -e "${RED}${BOLD}ERROR:${RESET} Missing parameters for background reminder."
                echo -e "Usage: remind-me -b \"Message\" <time_specification>"
                echo
                exit 1
            fi
            # Remove the -b flag and pass the rest to the background function
            shift
            run_background_reminder "$@"
            ;;
        "-h"|"--help")
            show_help
            ;;
        *)
            # If first argument doesn't match any command and we have at least 2 args
            if [ $# -lt 2 ]; then
                echo
                echo -e "${RED}${BOLD}ERROR:${RESET} Missing parameters!"
                echo -e "Run ${CYAN}remind-me --help${RESET} for usage information."
                echo
                exit 1
            fi
            
            # Run as standard reminder
            set_reminder "$@"
            ;;
    esac
}

# Execute main with all arguments
main "$@"
