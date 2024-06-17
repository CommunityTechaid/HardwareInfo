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

theta_ip=10.0.0.1

# Stop existing NTP daemon to allow other connections on the ntp socket
echo "[$(date)] Stopping NTP daemon"
/etc/init.d/S49ntp stop

# Run NTP with one shot settings
echo "[$(date)] Querying time server on Theta (""$theta_ip"")..."
ntpdate 10.0.0.1

# Write to hardware clock
echo "[$(date)] Setting correct time"
hwclock -w

exit
