#! /usr/bin/bash

date_string="$(date +%Y-%m-%d)"
serial_number=$(lshw -class system -json | jq -r '.[0].serial')

generate_filename () {
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
    # Create local file prefix
    local_filename='nwipe_log_'"$date_string"'--'"$serial_number"
    # Grep local file for status
    # grep -q Pass ./"$local_filename"*
    # grep_pass_status=$?
    # grep -q Failed ./"$local_filename"*
    # grep_fail_status=$?

    # Grep will return successful exit code on finding the string
    if grep -q 'Nwipe successfully completed.' ./"$local_filename"*; then
        wipe_status="Wiped."
    else
        # More logic needed to handle aborted / other messages
        wipe_status="FAILED!"
    fi
    # Echo to return the string, tee to also output to plain text file for ease of lookup
    # in other post_ scripts
    echo $wipe_status | tee WIPE_STATUS.txt
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
    --ok-label "I have labelled the device." \
    --backtitle "CTA Device ID" \
    --title 'CTA ID'\
    --msgbox "Device ID: $device_id

Wipe status: $wipe_status

Please make sure the device is labelled.

Press enter to continue." \
    0 0

exit
