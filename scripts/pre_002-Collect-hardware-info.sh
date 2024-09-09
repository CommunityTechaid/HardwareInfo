#! /usr/bin/bash
#####################
#
# Script to programmatically collect hardware infomation to then add to TaDa
#
# reqs: --
# input: CTA_ID file for ID
# output: /usr/output/$(date +%Y-%m-%d)--$device_id--$system_serial_number.json - .json file containing hardware info
#
#####################

##
## HELPER FUNCTIONS
##
exists() { [[ -f $1 ]]; }

##
## Variables
##

output_dir="/usr/output"

#####################

## Device ID from file
if [[ -f CTA_ID ]]; then
    device_id=$(<CTA_ID)
else
    device_id=0000
fi

#get device type - the returned value is a number that can be looked up on https://www.dmtf.org/standards/SMBIOS
# 2 -> Unknown
#refer https://superuser.com/questions/877677/programatically-determine-if-an-script-is-being-executed-on-laptop-or-desktop
exists /sys/class/dmi/id/chassis_type && device_type=$(</sys/class/dmi/id/chassis_type) || device_type='2'

#GET SYSTEM INFO WITH lshw
system_info=$(lshw -json)

system_manufacturer=$(jq -r '.vendor' <<< "$system_info")
system_serial_number=$(jq -r '.serial' <<< "$system_info")

# Swap model & versions for Lenovo as human readable is version for Lenovo
if [[ $system_manufacturer == "LENOVO" ]]; then
    system_model=$(jq -r '.version' <<< "$system_info")
    system_version=$(jq -r '.product' <<< "$system_info")
else
    system_model=$(jq -r '.product' <<< "$system_info")
    system_version=$(jq -r '.version' <<< "$system_info")
fi


##
## CPU Details
##
cpu_info=$(lshw -json -class cpu)

cpu_type=$(jq -r '.[].product' <<< "$cpu_info")
cpu_bits=$(jq -r '.[].width' <<< "$cpu_info")
cpu_cores=$(jq -r '.[].configuration.cores' <<< "$cpu_info")

if [[ -f /sys/class/tpm/tpm0/tpm_version_major ]]; then
    tpm_version=$(</sys/class/tpm/tpm0/tpm_version_major)
else
    tpm_version="No TPM"
fi

##
## RAM
##
ram_installed=$(jq -r '.children[] | select(.id == "core").children[] | select(.id == "memory").size ' <<< "$system_info")

##
## Storage details
##
declare -a disk_names
declare -a disk_sizes
declare -a is_hdd

disk_info=$(lsblk --path -AdJbo NAME,SIZE,ROTA)
disk_names+=($(jq -r '.blockdevices[] | .name' <<< "$disk_info"))
disk_sizes+=($(jq -r '.blockdevices[] | .size' <<< "$disk_info"))
is_hdd+=($(jq -r '.blockdevices[] | .rota' <<< "$disk_info"))

disk_number=$(jq '.blockdevices' <<< "$disk_info" | jq length)

total_storage=0
for ((i=1;i<=disk_number;i++)); do
    total_storage+=${disk_sizes[$i]}
done

##
## BATTERY HEALTH
## Only works on one battery for the moment.
##
batt_root="/sys/class/power_supply/BAT0"
batt_current_capacity=$(<"$batt_root/energy_full")
batt_design_capacity=$(<"$batt_root/energy_full_design")
# Weirdly bc insists on added two decimal points for every scale / level of accuracy so stick to two and drop the .00
batt_health=$(echo "scale=2; $batt_current_capacity / $batt_design_capacity" | bc | cut -d . -f 2)


output_string=$(jq -n \
                   --arg id "$device_id" \
                   --arg make "$system_manufacturer" \
                   --arg model "$system_model" \
                   --arg version "$system_version" \
                   --arg serialNo "$system_serial_number" \
                   --arg cpuType "$cpu_type" \
                   --arg cpuBits "$cpu_bits" \
                   --arg cpuCores "$cpu_cores" \
                   --arg tpmVersion "$tpm_version" \
                   --arg ramCapacity "$ram_installed" \
                   --arg type "$device_type" \
                   --arg typeOfStorage "$is_hdd" \
                   --arg storageCapacity "$disk_sizes" \
                   '$ARGS.named')


##
## write output data to file
##

if [ ! -d "$output_dir" ]; then
    mkdir $output_dir
fi

echo "$output_string" > "${output_dir}/$(date +%Y-%m-%d)--$device_id--$system_serial_number.json"

### PRINTING FOR TROUBLESHOOTING
#
# printf "DISK NUMBER $disk_number"
##
## DISPLAY SYSTEM INFORMATION
##
#printf \
#"# System info #
#
#Vendor: %s
#Model: %s
#Version: %s
#Serial Number: %s
#
#CPU: %s
#CPU bits: %s
#CPU cores: %s
#
#TPM version: %s
#
#RAM: %s
#
#Device Type Key: %s
#" \
#"$system_manufacturer" \
#"$system_model" \
#"$system_version" \
#"$system_serial_number" \
#"$cpu_type" \
#"$cpu_bits" \
#"$cpu_cores" \
#"$tpm_version" \
#"$ram_installed" \
#"$device_type"
#
##################################
#
exit
