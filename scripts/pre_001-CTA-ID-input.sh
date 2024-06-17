#! /usr/bin/bash
###
#
# Script to capture CTA ID input from users
#
###

exec 3>&1

# Define top title
dlg_backtitle="Community TechAid drive eraser (feat. ShredOS and nwipe)"

# Define helper function with defaults
dlg () {
    dialog --no-cancel --colors --backtitle "${dlg_backtitle}" "$@"  2>&1 1>&3
}

get_device_id () {
    DEV_ID=$(dlg --title 'Device ID' \
                 --inputbox  "Enter the device ID from the CTA sticker.\n\nIf it doesn't have one, enter 0000" \
                 10 30)
}

check_id () {
    if [[ ! $DEV_ID =~ ^[0-9]+$ ]]; then
        dlg --title 'ID check' \
            --msgbox "You have entered \Zb\Z1${DEV_ID}\Zn, which is not a proper ID number.\n\nTry again" \
            10 30
        return 1
    fi
}

confirm_id () {
    dlg --title 'Confirmation' \
        --yesno "You have entered \Zb\Z1${DEV_ID}\Zn\n\nIs this the correct device ID?" 10 30
}

until get_device_id && check_id && confirm_id; do :; done

# Output $DEV_ID var to CTA_ID file
echo "$DEV_ID" > CTA_ID

clear

exec 3>&-

exit
