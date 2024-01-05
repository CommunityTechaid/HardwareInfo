#! /usr/bin/zsh
###
#
# Script to gather HW info from devices
#
###
#
# TODO:
# HDD
#    - number
#    - capacity(s)
#    - HDD vs SSD
#    - health
# Battery
#    - design capacity
#    - current capacity
#    - health
#
###
# required tools: jq, lshw, acpitool, smartmontools 

system_info=$(sudo lshw -json)

system_manufacturer=$(jq '.vendor' <<< "$system_info")
system_serial_number=$(jq '.serial' <<< "$system_info")
system_model=$(jq '.product' <<< "$system_info")
system_version=$(jq '.version' <<< "$system_info")

cpu_info=$(sudo lshw -json -class cpu)

cpu_type=$(jq '.[].product' <<< "$cpu_info")
cpu_bits=$(jq '.[].width' <<< "$cpu_info")
cpu_cores=$(jq '.[].configuration.cores' <<< "$cpu_info")

tpm_version=$(sudo cat /sys/class/tpm/tpm0/tpm_version_major)

ram_installed=$(jq '.children[] | select(.id == "core").children[] | select(.id == "memory").size ' <<< "$system_info" | numfmt --to=iec)

#declare -a disk_list
declare -a disk_names
declare -a disk_sizes
declare -a is_hdd
#declare -A disk_array

disk_info=$(lsblk --path -AdJo NAME,SIZE,ROTA)
disk_names+=($(jq -r '.blockdevices[] | .name' <<< "$disk_info"))
disk_sizes+=($(jq '.blockdevices[] | .size' <<< "$disk_info"))
is_hdd+=($(jq '.blockdevices[] | .rota' <<< "$disk_info"))

#disk_list+=($(lsblk -aAJ | jq '.blockdevices[] | select(.type="disk") | .name'))

#for i in $disk_list;
#    do 
#        size=$(lsblk -aAJ | jq '.blockdevices[] | select(.type="disk") | select(.name="$i") | .size')
#        disk_array[$i]+=$size
#    done

disk_number=$(jq length <<< "$disk_info")

printf \
"# System info #

Vendor: %s
Model: %s
Version: %s
Serial Number: %s

CPU: %s
CPU bits: %s
CPU cores: %s

TPM version: %s

RAM: %s

" \
"$system_manufacturer" \
"$system_model" \
"$system_version" \
"$system_serial_number" \
"$cpu_type" \
"$cpu_bits" \
"$cpu_cores" \
"$tpm_version" \
"$ram_installed" 

printf "Disk number : %s\n" "$disk_number"
printf "\n\n# DISK INFO #\n"
printf "%-15s %-10s %-10s \n" \
	"NAME" "SIZE" "HDD"

for ((i=1;i<=disk_number;i++)); do 
	printf "%-15s %-10s %-10s \n" \
		"$disk_names[$i]" \
		"$disk_sizes[$i]" \
		"$is_hdd[$i]"
	done


printf "\n\n# DISK HEALTH REPORTS #\n\n"
for name in ${disk_names[@]};
do 
	#this command works in shell but cannot find device type when run through the script. 
	disk_health=$(sudo smartctl -s on -a "$name")
	printf "%s" "$disk_health"
done

printf "\n\n# BATTERY HEALTH #\n\n"
# /sys/class/power_supply/BAT* could have different files apparently according to whether AC is conencted or not
# In order to handle this, we check the files before we parse them. The files could either be energy_* or charge_*

#get battery model
{ battery_model=$(< /sys/class/power_supply/BAT*/model_name | head -n 1); } 2> /dev/null
printf "Batter Model: %s \n" "$battery_model"

#get battery technology
{ battery_tech=$(< /sys/class/power_supply/BAT*/technology | head -n 1); } 2> /dev/null
printf "Batter Model: %s \n" "$battery_tech"

#[[ -f foo.txt ]] && s=$(<foo.txt) || s=''

battery_rated_is_available=0
battery_current_is_available=0

# get the rated or designed capacity
if [ -f /sys/class/power_supply/BAT*/energy_full_design ]
then
        #we take the first value in case of multiple batteries found
        battery_capacity_rated=$(cat /sys/class/power_supply/BAT*/energy_full_design | head -n 1)
        battery_rated_is_available=1

elif [ -f /sys/class/power_supply/BAT*/charge_full_design ]
then
        #we take the first value in case of multiple batteries found
        battery_capacity_rated=$(cat /sys/class/power_supply/BAT*/charge_full_design | head -n 1)
        battery_rated_is_available=1
fi

# get the actual capacity currently
if [ -f /sys/class/power_supply/BAT*/energy_full ]
then
        #we take the first value in case of multiple batteries found
        battery_capacity_current=$(cat /sys/class/power_supply/BAT*/energy_full | head -n 1)
        battery_current_is_available=1

elif [ -f /sys/class/power_supply/BAT*/charge_full ]
then
        #we take the first value in case of multiple batteries found
        battery_capacity_current=$(cat /sys/class/power_supply/BAT*/charge_full | head -n 1)
        battery_current_is_available=1
fi

if [[ $battery_rated_is_available && $battery_current_is_available ]]
then
        battery_health=$((($battery_capacity_current*100)/$battery_capacity_rated))
        printf "Battery Health: %d%%\n" "$battery_health"
else
        print "Battery Health: Not found"
fi


