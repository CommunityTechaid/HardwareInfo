#! /usr/bin/bash
#####################
#
# Script to display CTA ID and wipe status to user
#
# reqs: --
# input: CTA_ID file,
#        nwipe log file
# output: WIPE_STATUS - file containing wipe status of the device
#
#####################


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
    # local_filename='nwipe_log_'"$date_string"'--'"$serial_number"
    local_filename='nwipe_log_'"$date_string"'--'"$device_id"'--'"$serial_number"
    # Grep local file for status
    # grep -q Pass ./"$local_filename"*
    # grep_pass_status=$?
    # grep -q Failed ./"$local_filename"*
    # grep_fail_status=$?

    # Grep will return successful exit code on finding the string
    # nwipe/ShredOS moves output to /exported on completion.
    if grep -q 'Nwipe successfully completed.' /exported/"$local_filename"*; then
        wipe_status="Wiped."
    else
        # More logic needed to handle aborted / other messages
        wipe_status="FAILED!"
    fi
    # Echo to return the string, tee to also output to plain text file for ease of lookup
    # in other post_ scripts
    echo $wipe_status | tee WIPE_STATUS
}

# target=$(generate_filename)
# get_target_filename "$target"
device_id="$(<CTA_ID)"
wipe_status=$(get_wipe_status)

# Translate to TaDa statuses and then push to Theta
# Device wiped = PROCESSING_WIPED
# Device wipe failed = PROCESSING_FAILED_WIPE

if [ "$wipe_status" = "Wiped." ]; then
    echo "PROCESSING_WIPED" > STATUS
else
    echo "PROCESSING_FAILED_WIPE" > STATUS
fi

# Create .json format to push
output_string=$(jq -n \
                   --arg id "$device_id" \
                   --arg status "$(<STATUS)" \
                   '$ARGS.named')

echo "$output_string" > "$device_id".status

# Get kernel params with deets in to push status to Theta
lftp_user=$(kernel_cmdline_extractor lftp_user)
lftp_pass=$(kernel_cmdline_extractor lftp_pass)

# Construct command string
lftp_command="open 10.0.0.1; \
            user $lftp_user $lftp_pass; \
            cd test-shredos/statuses; \
            put $device_id.status ; \
            exit"

lftp -c "$lftp_command"


dialog \
    --aspect 4 \
    --cr-wrap \
    --no-cancel \
    --no-collapse \
    --colors \
    --ok-label "I have labelled the device." \
    --backtitle "Community TechAid drive eraser (feat. ShredOS and nwipe)" \
    --title 'CTA Wipe - Summary'\
    --msgbox "Device ID: $device_id

Wipe status: $wipe_status

Please make sure the device is labelled.

Press enter to continue." \
    15 40

exit
