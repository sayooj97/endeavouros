#!/bin/bash

# Get the list of connected monitors
connected_monitors=$(hyprctl monitors | grep "Monitor" | awk '{print $2}')

# Define your monitor names
INTERNAL_DISPLAY="eDP-1"   # Laptop screen (change this based on `hyprctl monitors`)
EXTERNAL_DISPLAY="HDMI-A-1" # HDMI monitor (change this as needed)

# Check if HDMI is connected
if echo "$connected_monitors" | grep -q "$EXTERNAL_DISPLAY"; then
    # If HDMI is connected, disable internal screen and enable external
    hyprctl keyword monitor "$INTERNAL_DISPLAY,disable"
    hyprctl keyword monitor "$EXTERNAL_DISPLAY,preferred,auto,1"
    notify-send "HDMI Connected" "Using external screen only"
else
    # If HDMI is disconnected, re-enable internal screen
    hyprctl keyword monitor "$INTERNAL_DISPLAY,preferred,auto,1"
    notify-send "HDMI Disconnected" "Reverting to internal screen"
fi
