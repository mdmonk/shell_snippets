#!/bin/bash
#####
# $1 is the name of the ISO passed in.
/usr/bin/sudo /usr/bin/cdrecord -v -eject speed=16 driveropts=burnfree dev=ATA:1,0,0 $1

#if ["$1x" eq "x"]; then
# echo "No iso name passed in!"
#else
# echo "\$1 is: $1"
#fi
