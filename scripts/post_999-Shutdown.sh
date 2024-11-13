#!/usr/bin/bash
#####################
#
# Script to display warning dialog before shutting down the machine
#
# reqs: --
# input: --
# output: --
#
#####################

dialog \
    --aspect 4 \
    --cr-wrap \
    --no-cancel \
    --no-collapse \
    --colors \
    --ok-label "Shutdown" \
    --backtitle "CTA Device Wiping" \
    --title 'CTA Wipe - Shutdown'\
    --msgbox "Press enter to shutdown." \
    20 40

# Use exit status so ESC (exit status 255) can avoid poweroff for testing etc.
exit_status=$?
if [ $exit_status -eq 0 ]; then
    poweroff
fi
