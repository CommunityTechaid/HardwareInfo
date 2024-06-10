#!/usr/bin/bash
###
# Script to sync hardware clock with NTP
###

# Stop existing NTP daemon
/etc/init.d/S49ntp stop

# Run NTP with one shot settings
# -q - run once and quit (rather than forking into daemon)
# -g - don't panic at large time differences
ntpdate -qg 10.0.0.1

# Write to hardware clock
hwclock -w
