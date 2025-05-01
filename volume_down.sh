#!/bin/bash
# Script to decrease audio volume by 5%
# For Pipewire on Arch Linux/KDE

# Function to decrease volume by 5%
decrease_volume() {
    # Get current volume
    current_volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -oP 'Volume: \K[0-9.]+')
    
    # Decrease volume by 5% (0.05)
    wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    
    # Show notification with "Volume Down" message
    notify-send -u normal -i audio-volume-low "Volume Down" "Volume decreased" -t 1500
}

# Execute the volume decrease function
decrease_volume
