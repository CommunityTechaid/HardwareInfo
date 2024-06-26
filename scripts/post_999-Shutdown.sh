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
    --title 'CTA ID'\
    --msgbox "Press enter to shutdown." \
    10 30

# Use exit status so ESC (exit status 255) can avoid poweroff for testing etc.
exit_status=$?
if [ $exit_status -eq 0 ]; then
    poweroff
fi
