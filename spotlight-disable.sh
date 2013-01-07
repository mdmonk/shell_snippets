#!/bin/bash

sudo mdutil -i off /
sudo mdutil -E /

echo "You must now change the /etc/hostconfig file"
echo "Locate the SPOTLIGHT entry and change it to '-NO-'"
sleep 3
sudo vi /etc/hostconfig
