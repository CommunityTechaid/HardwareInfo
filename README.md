# CTA Hardward Info Collection Script

Inital version of script to collect hardware info

The scripts directory contains two scripts that are ready to go on the server from where shredOs should pick it up in the pre wipe hook. 

## pre_001-CTA-ID-input.sh

This script should get the device serial ID and then display it for quick creation of device on the app.  

## pre_002-Collect-hardware-info.sh

This script collects important hardware information and dumps it into device_####.json file which is then stored in the output directory (Currently set to /usr/output)

## pre_003-Set-HWclock-to-NTP.sh

This script queries timeserver on the network to set hardware clock to the current time to avoid issues with device logs having the wrong timestamps

## post_001-ID-lookup.sh

This script gathers information, ftps it to Theta and presents it in a GUI to the user
	
## post_999-Shutdown.sh

Presents GUI to shutdown device
	
	
	
