#! /usr/bin/bash

generate_filename () {
    date_string="$(date +%Y-%m-%d)"
    serial_number=$(lshw -class system -json | jq -r '.[0].serial')
    target_filename="$date_string--$serial_number"
    echo "$target_filename"
}

get_target_filename () {
    # Dir on Theta is /srv/netboot/log/test-shredos/CTA-IDs/
    # LFTP home should be /srv/netboot/log/, hence the shorter
    filename=$1
    base_dir="/test-shredos/CTA-IDs"
    lftp -c "open 10.0.0.1; user netboot-log ThreeInOne\!; cd $base_dir; get $filename -o DEVICE_ID.txt"
}

target=$(generate_filename)
get_target_filename "$target"

echo "$target"
echo "$(<DEVICE_ID.txt)"
echo " !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! "

read -n 1 -p "PRESS A BUTTON TO CONTINUE"

exit
