#!/bin/bash
# Script to increase audio volume by 5%
# For Pipewire on Arch Linux/KDE

# Function to increase volume by 5%
increase_volume() {
    # Get current volume
    current_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oP 'Volume: \K[0-9.]+')
    
    # Check if audio is muted first - unmute if needed
    is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)
    if [ "$is_muted" -eq "1" ]; then
        wpctl set-mute @DEFAULT_AUDIO_SINK@ 0
    fi
    
    # Check if current volume is already at or near 100%
    if (( $(echo "$current_volume >= 0.95" | bc -l) )); then
        # If we're already at 95% or higher, set to exactly 100%
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0
    else
        # Otherwise increase by 5%
        wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
    fi
    
    # Show notification with "Volume Up" message
    notify-send -u normal -i audio-volume-high "Volume Up" "Volume increased" -t 1500
}

# Execute the volume increase function
increase_volume
