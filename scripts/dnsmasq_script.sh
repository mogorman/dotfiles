#!/usr/bin/env bash
if [[ "$2" == "9c:8e:cd:30:9b:d5" || "$2" == "9c:8e:cd:37:ce:12" ]]; then
	sleep 30
	curl 'http://frontdoor/cgi-bin/configManager.cgi?action=setConfig&VideoWidget%5B0%5D.TimeTitle.EncodeBlend=false&VideoWidget%5B0%5D.PictureTitle.EncodeBlend=false' --digest -u $CREDS
	curl 'http://sidedoor/cgi-bin/configManager.cgi?action=setConfig&VideoWidget%5B0%5D.TimeTitle.EncodeBlend=false&VideoWidget%5B0%5D.PictureTitle.EncodeBlend=false' --digest -u $CREDS
fi
