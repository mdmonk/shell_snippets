#!/bin/bash

/sbin/service NetworkManager stop
sleep 2
/usr/sbin/wpa_supplicant -c /etc/wpa_supplicant/wpa_supplicant.conf -D wext -i eth1 -f -d -B -w
sleep 3
/sbin/dhclient eth1
