#!/bin/bash

dir="$HOME/.config/rofi/applets/type-4"
theme='style-1'

# Bluetooth Menu Options as Variables
POWER_ON=""
POWER_OFF=""
SCAN=""
CONNECT=""
REMOVE=""
EXIT=""

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p " Bluetooth" \
        -theme ${dir}/${theme}.rasi
}

# Bluetooth Menu with Variables
bluetooth_menu() {
    echo -e "$POWER_ON\n$POWER_OFF\n$SCAN\n$CONNECT\n$REMOVE\n$EXIT" | rofi_cmd
}

# Scan for devices
scan_devices() {
    # Clear previous scan cache
    bluetoothctl remove $(bluetoothctl devices | awk '{print $2}') > /dev/null 2>&1

    # Start scanning silently
    bluetoothctl scan on > /dev/null 2>&1 &
    sleep 5
    bluetoothctl scan off > /dev/null 2>&1

    # Get newly found devices
    bluetoothctl devices |
        grep '^Device' |
        awk '{for (i=3; i<=NF; i++) printf "%s%s", $i, (i==NF ? ORS : OFS)}' |
        sort -u
}
# previous scan version
# scan\_devices() {
# bluetoothctl scan on &
# sleep 5
# bluetoothctl scan off
# bluetoothctl devices | awk '{\$1=\$2=""; print \$0}' | sed 's/^ \*//'
# } 


# Get saved/known devices
saved_devices() {
    bluetoothctl paired-devices | grep '^Device' | cut -d ' ' -f 3- | sed 's/^[ \t]*//;s/[ \t]*$//'
}




# Get MAC address from name
get_mac_by_name() {
    local name="$1"
    bluetoothctl devices | grep "$name" | awk '{print $2}'
}

# Ensure Bluetooth is unblocked and powered on
rfkill unblock bluetooth
bluetoothctl power on > /dev/null

# Main Loop
while true; do
    CHOICE=$(bluetooth_menu)

    case "$CHOICE" in
        "$POWER_ON")
            bluetoothctl power on
            notify-send "Bluetooth" "Turned On"
            ;;
        "$POWER_OFF")
            bluetoothctl power off
            notify-send "Bluetooth" "Turned Off"
            ;;
        "$SCAN")
            DEVICE_LIST=$(scan_devices)
            [ -z "$DEVICE_LIST" ] && notify-send "Bluetooth" "No devices found" && continue
            SELECTED=$(echo "$DEVICE_LIST" | rofi_cmd)
            [ -z "$SELECTED" ] && continue
            MAC=$(get_mac_by_name "$SELECTED")
            bluetoothctl pair "$MAC"
            bluetoothctl trust "$MAC"
            bluetoothctl connect "$MAC"
            notify-send "Bluetooth" "Connected to $SELECTED"
            ;;
        "$CONNECT")
            DEVICE_LIST=$(saved_devices)
            [ -z "$DEVICE_LIST" ] && notify-send "Bluetooth" "No saved devices" && continue
            SELECTED=$(echo "$DEVICE_LIST" | rofi_cmd)
            [ -z "$SELECTED" ] && continue
            MAC=$(get_mac_by_name "$SELECTED")
            bluetoothctl connect "$MAC" && notify-send "Bluetooth" "Connected to $SELECTED" || notify-send "Bluetooth" "Failed to connect"
            ;;
        "$REMOVE")
            DEVICE_LIST=$(saved_devices)
            [ -z "$DEVICE_LIST" ] && notify-send "Bluetooth" "No devices to remove" && continue
            SELECTED=$(echo "$DEVICE_LIST" | rofi_cmd)
            [ -z "$SELECTED" ] && continue
            MAC=$(get_mac_by_name "$SELECTED")
            bluetoothctl remove "$MAC" && notify-send "Bluetooth" "Removed $SELECTED" || notify-send "Bluetooth" "Failed to remove $SELECTED"
            ;;
        "$EXIT" | "")
            exit 0
            ;;
        *)
            notify-send "Bluetooth" "Invalid Option"
            ;;
    esac
done
