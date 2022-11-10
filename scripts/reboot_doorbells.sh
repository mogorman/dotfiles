#!/usr/bin/env bash
echo "rebooting doorbells"
#sleep $((RANDOM%3600))
curl  'http://sidedoor/cgi-bin/magicBox.cgi?action=reboot' -v -v --digest -u "$CREDS"
#sleep 300
curl  'http://frontdoor/cgi-bin/magicBox.cgi?action=reboot' -v -v --digest -u "$CREDS"
echo "Done rebooting doorbells"
