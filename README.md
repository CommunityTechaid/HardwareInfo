# CTA Hardward Info Collection Script

Inital version of script to collect hardware info

The scripts directory contains two scripts that are ready to go on the server from where shredOs should pick it up in the pre wipe hook. 

### pre\_001serial.sh

This script should get the device serial ID and then display it for quick creation of device on the app.  

### pre\_002steph.sh

This script collects important hardware information and dumps it into device_####.json file which is then stored in the output directory (Currently set to /usr/output)

