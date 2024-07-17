#! /usr/bin/bash
#####################
#
# Script to capture CTA ID input from users
#
# reqs: --
# input: User input CTA device ID
# output: CTA_ID - simple file containing CTA device id
#         STATUS - simple file containing status
#
#####################

exec 3>&1

# Define top title
dlg_backtitle="Community TechAid drive eraser (feat. ShredOS and nwipe)"

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
    DEV_ID=$(dlg --title 'CTA Wipe - Device ID' \
                 --inputbox  "Enter the device ID from the CTA sticker.\n\nIf it doesn't have one, enter 0000" \
                 15 40)
}

check_id () {
    if [[ ! $DEV_ID =~ ^[0-9]+$ ]]; then
        dlg --title 'CTA Wipe - ID verification' \
            --msgbox "You have entered \Zb\Z1${DEV_ID}\Zn, which is not a proper ID number.\n\nTry again" \
            15 40
        return 1
    fi
}

confirm_id () {
    dlg --title 'CTA Wipe - ID confirmation' \
        --yesno "You have entered \Zb\Z1${DEV_ID}\Zn\n\nIs this the correct device ID?" 10 30
}

until get_device_id && check_id && confirm_id; do :; done

# Output $DEV_ID var to CTA_ID file
echo "$DEV_ID" > CTA_ID

# Set STATUS to received as device now deffo in the building
# PROCESSING_START == Received
echo "PROCESSING_START" > STATUS

# Create .json format to push
output_string=$(jq -n \
                   --arg id "$DEV_ID" \
                   --arg status "$(<STATUS)" \
                   '$ARGS.named')

echo "$output_string" > "$DEV_ID".status

# Get kernel params with deets in to push status to Theta
lftp_user=$(kernel_cmdline_extractor lftp_user)
lftp_pass=$(kernel_cmdline_extractor lftp_pass)

# Construct command string
lftp_command="open 10.0.0.1; \
            user $lftp_user $lftp_pass; \
            cd test-shredos/statuses; \
            put $DEV_ID.status ; \
            exit"

lftp -c "$lftp_command"

clear

exec 3>&-

exit
