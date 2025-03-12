# CTA Hardware Info Collection Script

A collection of scripts to collect hardware details of machines and generate a .json file to be ingested by TaDa.

The scripts directory contains the scripts that are ready to go on the server from where [CTA ShredOS](https://github.com/CommunityTechaid/CTA-ShredOS) or [CTA HardwareOS](https://github.com/CommunityTechaid/HardwareOS) should pick them up and then runs them in numerical order.

## Prerequisites

These packages are needed to run the scripts:
- `jq`
- `lshw`
- `lftp`
- `dialog`
- `lsblk` part of `util-linux`
- `hwclock` also part of `util-linux`
- `ntpdate` part of `ntp`

Whilst these are needed for testing, both CTA ShredOS and CTA HardwareOS are built with them included by default.

## Setup

Setting up is just a case of copying the scripts to a location on Theta that's readable by ftp from CTA ShredOS / HardwareOS. Typically `/srv/netboot/log/scripts`.

## Scripts
### ./scripts/pre_001-CTA-ID-input.sh

This script create the UI for inputting the device ID. 

### ./scripts/pre_002-Collect-hardware-info.sh

This script collects important hardware information and dumps it into device_####.json file which is then stored in the output directory (Currently set to /usr/output)

### ./scripts/pre_003-Set-HWclock-to-NTP.sh

This script queries timeserver on the network to set hardware clock to the current time to avoid issues with device logs having the wrong timestamps.

### ./scripts/post_001-ID-lookup.sh

This script gathers information, ftps it to Theta and presents it in a UI to the user
	
### ./scripts/post_999-Shutdown.sh

Presents GUI to shutdown device
	
### CTA-HardwareInfo.sh

This is a standalone script for testing. Largely outdated.
