#!/bin/bash

sudo mdutil -i on /

echo "You must now change the /etc/hostconfig file"
echo "Locate the SPOTLIGHT entry and change it to '-YES-'"
sleep 3
sudo vi /etc/hostconfig
