#!/bin/bash
# Script to toggle microphone mute status on keypress
# For Pipewire on Arch Linux/KDE

# Function to get the default source (microphone)
get_default_source() {
    # Using wpctl to get the default audio source
    default_source=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | cut -d' ' -f1)
    echo "$default_source"
}

# Function to toggle mute status
toggle_mute() {
    # Toggle mute status using wpctl
    wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
    
    # Get current mute status to provide notification
    is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | grep -c MUTED)
    
    if [ "$is_muted" -eq "1" ]; then
        notify-send -u normal -i microphone-sensitivity-muted "Microphone" "Microphone Muted" -t 1500
    else
        notify-send -u normal -i microphone-sensitivity-high "Microphone" "Microphone Unmuted" -t 1500
    fi
}

# Main function
main() {
    toggle_mute
}

# Execute main function
main