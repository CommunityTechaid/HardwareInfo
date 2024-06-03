#! /usr/bin/bash
# exec 3>&1
dlg_backtitle="Community TechAid - Device Serial"


dlg () {
    # dialog --no-cancel --colors --backtitle "${dlg_backtitle}" "$@"  2>&1 1>&3
    dialog --no-cancel --colors --backtitle "${dlg_backtitle}" "$@"
}

#GET SYSTEM INFO WITH lshw
system_info=$(lshw -json)
system_serial_number=$(jq -r '.serial' <<< "$system_info")

show_serial_number () {
    dlg --title 'SERIAL NUMBER'\
        --yesno "Serial Number is \n\n\n        $system_serial_number \n\n\nHave you entered the serial number in the CTA app?" 20 30
}

until show_serial_number; do :; done

clear

# exec 3>&-
