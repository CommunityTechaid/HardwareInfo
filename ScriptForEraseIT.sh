#!/bin/bash
# Wrapper script to run hardware collection script in EraseIT enviroment
# Needs to be run as root 'coz lshw doesn't pick uip serial numbers otherwise

# Look for FTP login details
# source Theta.config

user=netboot-log
pass=ThreeInOne!

exec 3>&1

# Define top title
dlg_backtitle="Community TechAid Hardware Info Collection"

# Define helper function with defaults
dlg () {
    dialog \
        --aspect 4 \
        --no-cancel \
        --colors \
        --backtitle "${dlg_backtitle}" \
        "$@" \
        2>&1 1>&3
}

get_device_id () {
    DEV_ID=$(dlg --title 'No Wipe Report Detected' \
                 --inputbox  "Enter the device ID from the CTA sticker.\n\nIf it doesn't have one, enter 0000" \
                 15 40)
}

check_id () {
    if [[ ! $DEV_ID =~ ^[0-9]+$ ]]; then
        dlg --title 'ID verification' \
            --msgbox "You have entered \Zb\Z1${DEV_ID}\Zn, which is not a proper ID number.\n\nTry again" \
            15 40
        return 1
    fi
}

confirm_id () {
    dlg --title 'ID confirmation' \
        --yesno "You have entered \Zb\Z1${DEV_ID}\Zn\n\nIs this the correct device ID?" 10 30
}


# Look for device ID
# File name contains ID
if [ -f /home/reports/*.json ]; then
    # .json file exists
    file_name=$(basename "$(ls /home/reports/*json)")
    # Get id from report name
    id=$(cut -d - -f 3 <<< "$file_name")
    # Get wipe status from report name
    wipe_report_status=$(cut -d "-" -f 6 <<< "$file_name" | cut -d "." -f 1)
else
    # Report doesn't exist so get ID from user
    until get_device_id && check_id && confirm_id; do :; done
    id=$DEV_ID
    # Presume failure if not report present
    wipe_report_status="Fail"
fi

# Verify wipe failure
if [[ $wipe_report_status != "Pass" ]]; then
    # Wipe success / failure dialog
    confirm_wipe_fail () {
        dlg --title 'Wipe confirmation' \
            --yesno "The wipe report indicated that the wipe failed. (Or there isn't a report.)\n\n Did the EraseIT wipe actually fail?" 10 30
    }

    confirm_wipe_fail
    # Exit code 0 => Yes chosen = Failed
    # Exit code 1 => No chosen = Wiped
    wipe_output=$?

else
    wipe_output=1
fi

# Device wiped = PROCESSING_WIPED
# Device wipe failed = PROCESSING_FAILED_WIPE
if [ $wipe_output == 1 ]; then
    status="PROCESSING_WIPED"
    # Create .json format to push
    output_string=$(jq -n \
                       --arg id "$id" \
                       --arg status "$status" \
                       '$ARGS.named')
else
    # Create .json format to push
    output_string=$(jq -n \
                       --arg id "$id" \
                       --argjson wipeFailed '"true"' \
                       '{id: $id, subStatus: { wipeFailed: $wipeFailed }}')
fi

# Create temp_dir to work in
temp_dir=$(mktemp -d)

echo "$output_string" > "$temp_dir"/"$id".status

# Construct command string
status_dir="shredos/statuses"
lftp_status_command="open 10.0.0.1; \
            user $user $pass; \
            cd $status_dir; \
            put $temp_dir/$id.status ; \
            exit"

lftp -c "$lftp_status_command"


# Fetch script
lftp_get_script="open 10.0.0.1; \
            user $user $pass; \
            cd scripts; \
            get pre_002-Collect-hardware-info.sh -o $temp_dir/; \
            exit"

lftp -c "$lftp_get_script"

# Edit scripts output dir
sed -i "s|/usr/output|$temp_dir|" $temp_dir/pre_002-Collect-hardware-info.sh

# Write device ID to file for script
echo $id > CTA_ID

# Make script executable
chmod +x $temp_dir/pre_002-Collect-hardware-info.sh
# Run script
$temp_dir/pre_002-Collect-hardware-info.sh

# Remove ID file
rm CTA_ID

# Get hardware info file 
hardware_info=$(basename $temp_dir/$(date +%Y-%m-%d)--$id--*.json)

# Construct command string
status_dir="shredos"
lftp_hw_command="open 10.0.0.1; \
            user $user $pass; \
            cd $status_dir; \
            put $temp_dir/$hardware_info ; \
            exit"


# echo $temp_dir
lftp -c "$lftp_hw_command"

confirm_finish() {
    dlg --title 'Hardware Info Collection Finished' \
        --msgbox "Hardware info collection has finished. \\n\\n \
Please: \\n\
    - double check TaDa \\n\
    - re-enable secure boot \\n\
    - label device as wiped" 15 40
}

confirm_finish
