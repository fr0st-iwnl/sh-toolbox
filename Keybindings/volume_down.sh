#!/bin/bash
# Script to decrease audio volume by 5%
# Supports both PulseAudio and Pipewire

# Configuration
# Set to "true" to enable notifications, "false" to disable
ENABLE_NOTIFICATIONS="true"

# Notification cooldown in seconds (prevents notification spam)
NOTIFICATION_COOLDOWN=0.5

# Lockfile for notification rate limiting
LOCKFILE="/tmp/volume_notification.lock"

# The amount to increase/decrease volume (in percent)
VOLUME_STEP=5

# Colors for terminal output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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
    
    # Check if lockfile exists and is recent
    if [ -f "$LOCKFILE" ]; then
        # Get the timestamp of the lockfile
        lockfile_time=$(stat -c %Y "$LOCKFILE")
        current_time=$(date +%s)
        time_diff=$((current_time - lockfile_time))
        
        # If the lockfile is newer than NOTIFICATION_COOLDOWN, skip notification
        if [ "$time_diff" -lt "$NOTIFICATION_COOLDOWN" ]; then
            return
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

# Function to decrease volume using Pipewire
decrease_volume_pipewire() {
    # Get current volume
    current_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oP 'Volume: \K[0-9.]+')
    
    # Decrease volume by specified step
    wpctl set-volume @DEFAULT_AUDIO_SINK@ ${VOLUME_STEP}%-
    
    # Get new volume level for notification
    new_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oP 'Volume: \K[0-9.]+')
    new_volume_percent=$(echo "$new_volume * 100" | bc | cut -d. -f1)
    echo -e "${YELLOW}Volume decreased${NC}"
    show_notification "audio-volume-low" "Volume Down" "Volume decreased"
}

# Function to decrease volume using PulseAudio
decrease_volume_pulseaudio() {
    # Get default sink (speaker/headphones)
    default_sink=$(pactl get-default-sink)
    
    # Decrease by specified step
    pactl set-sink-volume "$default_sink" -${VOLUME_STEP}%
    
    # Get new volume for notification
    new_volume=$(pactl get-sink-volume "$default_sink" | grep -oP '\d+%' | head -n 1 | tr -d '%')
    echo -e "${YELLOW}Volume decreased${NC}"
    show_notification "audio-volume-low" "Volume Down" "Volume decreased"
}

# Main function
main() {
    # Detect audio system
    audio_system=$(detect_audio_system)
    
    case "$audio_system" in
        "pipewire")
            decrease_volume_pipewire
            ;;
        "pulseaudio")
            decrease_volume_pulseaudio
            ;;
        *)
            echo "Error: No compatible audio system found. Please install PulseAudio or Pipewire."
            exit 1
            ;;
    esac
}

# Execute main function
main
