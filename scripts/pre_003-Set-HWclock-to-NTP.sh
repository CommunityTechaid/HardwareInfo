#!/usr/bin/bash
###
#
# Script to sync hardware clock with NTP
#
# (Current set up won't allow automatic syncing. ntpd needs multiple servers to 
# calculate drift / accuracy and only Theta / 10.0.0.1 is accessible over the
# wiping network.)
#
###

# Stop existing NTP daemon to allow other connections on the ntp socket
/etc/init.d/S49ntp stop

# Run NTP with one shot settings
ntpdate 10.0.0.1

# Write to hardware clock
hwclock -w
