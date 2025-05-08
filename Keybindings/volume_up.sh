#!/bin/bash
# Script to increase audio volume by 5%
# Supports both PulseAudio and Pipewire

# Configuration
# Set to "true" to enable notifications, "false" to disable
ENABLE_NOTIFICATIONS="true"

# Notification cooldown in seconds (prevents notification spam)
# Use integer value
NOTIFICATION_COOLDOWN=1

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

# Function to increase volume using Pipewire
increase_volume_pipewire() {
    # Check if audio is muted - unmute if needed
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
    fi
    
    # Get current volume - without using floating point math
    current_vol_text=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    
    # Check if already at max volume
    if echo "$current_vol_text" | grep -q "Volume: 1.00"; then
        echo -e "${YELLOW}Volume at maximum: 100%${NC}"
        show_notification "audio-volume-high" "Volume" "Volume at maximum"
    else
        # Otherwise increase by specified step
        wpctl set-volume @DEFAULT_AUDIO_SINK@ ${VOLUME_STEP}%+
        echo -e "${GREEN}Volume increased${NC}"
        show_notification "audio-volume-high" "Volume Up" "Volume increased"
    fi
}

# Function to increase volume using PulseAudio
increase_volume_pulseaudio() {
    # Get default sink (speaker/headphones)
    default_sink=$(pactl get-default-sink)
    
    # Check if audio is muted - unmute if needed
    if pactl get-sink-mute "$default_sink" | grep -q "yes"; then
        pactl set-sink-mute "$default_sink" 0
    fi
    
    # Get current volume percentage
    current_volume=$(pactl get-sink-volume "$default_sink" | grep -o '[0-9]*%' | head -n 1 | tr -d '%')
    
    # Check if volume is at or near 100%
    if [ -n "$current_volume" ] && [ "$current_volume" -ge 95 ]; then
        # Set volume to exactly 100%
        pactl set-sink-volume "$default_sink" 100%
        echo -e "${YELLOW}Volume at maximum: 100%${NC}"
        show_notification "audio-volume-high" "Volume" "Volume at maximum"
    else
        # Increase by specified step
        pactl set-sink-volume "$default_sink" +${VOLUME_STEP}%
        echo -e "${GREEN}Volume increased${NC}"
        show_notification "audio-volume-high" "Volume Up" "Volume increased"
    fi
}

# Main function
main() {
    # Detect audio system
    audio_system=$(detect_audio_system)
    
    case "$audio_system" in
        "pipewire")
            increase_volume_pipewire
            ;;
        "pulseaudio")
            increase_volume_pulseaudio
            ;;
        *)
            echo "Error: No compatible audio system found. Please install PulseAudio or Pipewire."
            exit 1
            ;;
    esac
}

# Execute main function
main
