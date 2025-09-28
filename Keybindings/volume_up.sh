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

# Colors
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Function to show notification with rate limiting
show_notification() {
    local icon="$1"
    local title="$2"
    local message="$3"
    
    if [ "$ENABLE_NOTIFICATIONS" != "true" ] || ! command -v notify-send &> /dev/null; then
        return
    fi
    
    if [ -f "$LOCKFILE" ]; then
        if command -v stat &> /dev/null; then
            lockfile_time=$(stat -c %Y "$LOCKFILE" 2>/dev/null || echo 0)
            current_time=$(date +%s)
            time_diff=$((current_time - lockfile_time))
            if [ "$time_diff" -lt "$NOTIFICATION_COOLDOWN" ]; then
                return
            fi
        fi
    fi
    
    touch "$LOCKFILE"
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

# Pipewire increase
increase_volume_pipewire() {
    if wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -q MUTED; then
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
    fi
    
    current_vol_text=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
    
    if echo "$current_vol_text" | grep -q "Volume: 1.00"; then
        echo -e "${YELLOW}Volume at maximum: 100%${NC}"
        show_notification "audio-volume-high" "Volume" "Volume at maximum (100%)"
    else
        wpctl set-volume @DEFAULT_AUDIO_SINK@ ${VOLUME_STEP}%+
        new_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100) "%"}')
        echo -e "${GREEN}Volume increased to $new_volume${NC}"
        show_notification "audio-volume-high" "Volume Up" "Now: $new_volume"
    fi
}

# PulseAudio increase
increase_volume_pulseaudio() {
    default_sink=$(pactl get-default-sink)
    
    if pactl get-sink-mute "$default_sink" | grep -q "yes"; then
        pactl set-sink-mute "$default_sink" 0
    fi
    
    current_volume=$(pactl get-sink-volume "$default_sink" | grep -o '[0-9]*%' | head -n 1 | tr -d '%')
    
    if [ -n "$current_volume" ] && [ "$current_volume" -ge 95 ]; then
        pactl set-sink-volume "$default_sink" 100%
        echo -e "${YELLOW}Volume at maximum: 100%${NC}"
        show_notification "audio-volume-high" "Volume" "Volume at maximum (100%)"
    else
        pactl set-sink-volume "$default_sink" +${VOLUME_STEP}%
        new_volume=$(pactl get-sink-volume "$default_sink" | grep -o '[0-9]*%' | head -n 1)
        echo -e "${GREEN}Volume increased to $new_volume${NC}"
        show_notification "audio-volume-high" "Volume Up" "Now: $new_volume"
    fi
}

# Main
main() {
    audio_system=$(detect_audio_system)
    
    case "$audio_system" in
        "pipewire") increase_volume_pipewire ;;
        "pulseaudio") increase_volume_pulseaudio ;;
        *) echo "Error: No compatible audio system found." ; exit 1 ;;
    esac
}

main