#! /usr/bin/bash

generate_filename () {
    date_string="$(date +%Y-%m-%d)"
    serial_number=$(lshw -class system -json | jq -r '.[0].serial')
    suffix=".json.CTAid"
    target_filename="$date_string--$serial_number""$suffix"
    echo "$target_filename"
}

get_target_filename () {
    # Dir on Theta is /srv/netboot/log/test-shredos/CTA-IDs/
    # LFTP home should be /srv/netboot/log/, hence the shorter
    filename=$1
    base_dir="/test-shredos/CTA-IDs"
    lftp -c "debug; open 10.0.0.1; user netboot-log ThreeInOne\!; cd $base_dir; get $filename -o DEVICE_ID.txt"
}

get_wipe_status () {
    # Find local file
    # Grep local file for status
    # echo string to display
    # ?? CHANGE nwipe logfile naming convention to include $targetfilename string ??
    return
}


target=$(generate_filename)
get_target_filename "$target"
device_id="$(<DEVICE_ID.txt)"
wipe_status=$(get_wipe_status)

dialog \
    --aspect 4 \
    --cr-wrap \
    --no-cancel \
    --no-collapse \
    --colors \
    --ok-label "Continue" \
    --backtitle "CTA Device ID" \
    --title 'CTA ID'\
    --msgbox "Device ID: $device_id

Wipe status: $wipe_status

Please label the device.

Press enter to continue." \
    0 0

exit
