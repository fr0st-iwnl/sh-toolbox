#!/bin/bash
# Script to toggle audio output mute status on keypress
# For Pipewire on Arch Linux/KDE

# Function to toggle audio output mute status
toggle_audio_mute() {
    # Toggle mute status using wpctl for audio output
    wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    
    # Get current mute status to provide notification
    is_muted=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | grep -c MUTED)
    
    if [ "$is_muted" -eq "1" ]; then
        notify-send -u normal -i audio-volume-muted "Audio" "Audio Muted" -t 1500
    else
        notify-send -u normal -i audio-volume-high "Audio" "Audio Unmuted" -t 1500
    fi
}

# Execute the audio mute toggle function
toggle_audio_mute