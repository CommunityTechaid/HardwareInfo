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



target=$(generate_filename)
get_target_filename "$target"
device_id="$(<DEVICE_ID.txt)"

echo "Target: $target"
echo "CTA ID: $device_id"
echo " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "

read -n 1 -p "PRESS A BUTTON TO CONTINUE"

# show_device_id () {
#     dialog \
#         --no-cancel \
#         --colors \
#         --backtitle "CTA Device ID" \
#         --title 'CTA ID'\
#         --infobox "Device ID: $device_id \n\n\nHave you entered the serial number in the CTA app?" \
#         30 60
# }

# until show_serial_number; do :; done

# clear

# exec 3>&-


exit
