#!/bin/bash
# Script to toggle microphone mute status on keypress
# Supports both PulseAudio and Pipewire

# Configuration
# Set to "true" to enable notifications, "false" to disable
ENABLE_NOTIFICATIONS="true"

# Notification cooldown in seconds (prevents notification spam) 
# Use integer value
NOTIFICATION_COOLDOWN=0.2

# Lockfile for notification rate limiting
LOCKFILE="/tmp/toggle_mic_notification.lock"

# Colors for terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to show notification with rate limiting
show_notification() {
    local icon="$1"
    local title="$2"
    local message="$3"
    
    # Only show notification if enabled and notify-send exists
    if [ "$ENABLE_NOTIFICATIONS" != "true" ] || ! command -v notify-send &> /dev/null; then
        return
    fi
    
    # Check for rate limiting
    if [ -f "$LOCKFILE" ]; then
        # Get the timestamp of the lockfile
        if command -v stat &> /dev/null; then
            lockfile_time=$(stat -c %Y "$LOCKFILE" 2>/dev/null || echo 0)
            current_time=$(date +%s)
            
            # Only do time check if we got valid times
            if [ -n "$lockfile_time" ] && [ -n "$current_time" ]; then
                time_diff=$((current_time - lockfile_time))
                
                # If the lockfile is newer than NOTIFICATION_COOLDOWN, skip notification
                if [ "$time_diff" -lt "$NOTIFICATION_COOLDOWN" ]; then
                    return
                fi
            fi
        fi
    fi
    
    # Update lockfile timestamp
    touch "$LOCKFILE"
    
    # Show notification
    notify-send -u normal -i "$icon" "$title" "$message" -t 1500
}

# Detect audio system (Pipewire or PulseAudio)
detect_audio_system() {
    if command -v wpctl &> /dev/null; then
        echo "pipewire"
    elif command -v pactl &> /dev/null; then
        echo "pulseaudio"
    else
        echo "unknown"
    fi
}

# Function to toggle microphone mute status using Pipewire
toggle_pipewire() {
    # Toggle mute status using wpctl
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    
    # Get new mute status
    is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -c MUTED)
    
    if [ "$is_muted" -eq "1" ]; then
        echo -e "${RED}Microphone Muted${NC}"
        show_notification "microphone-sensitivity-muted" "Microphone" "Microphone Muted"
    else
        echo -e "${GREEN}Microphone Unmuted${NC}"
        show_notification "microphone-sensitivity-high" "Microphone" "Microphone Unmuted"
    fi
}

# Function to toggle microphone mute status using PulseAudio
toggle_pulseaudio() {
    # Get default source (microphone)
    default_source=$(pactl get-default-source)
    
    # Toggle mute status
    pactl set-source-mute "$default_source" toggle
    
    # Get new mute status
    is_muted=$(pactl get-source-mute "$default_source" | grep -c "yes")
    
    if [ "$is_muted" -eq "1" ]; then
        echo -e "${RED}Microphone Muted${NC}"
        show_notification "microphone-sensitivity-muted" "Microphone" "Microphone Muted"
    else
        echo -e "${GREEN}Microphone Unmuted${NC}"
        show_notification "microphone-sensitivity-high" "Microphone" "Microphone Unmuted"
    fi
}

# Main function
main() {
    # Detect audio system
    audio_system=$(detect_audio_system)
    
    case "$audio_system" in
        "pipewire")
            toggle_pipewire
            ;;
        "pulseaudio")
            toggle_pulseaudio
            ;;
        *)
            echo "Error: No compatible audio system found. Please install PulseAudio or Pipewire."
            exit 1
            ;;
    esac
}

# Execute main function
main