#!/bin/bash

[ -x /usr/sbin/ioreg ] && \
    /usr/sbin/ioreg -p IODeviceTree -n "battery" -w 0 | \
    sed -ne '/| *{/,/| *}/ {
        s/^[ |]*//g
        /^[{}]/!p
    }' | \
    awk '/Battery/ {
        gsub("[{}()\"]","", $3)
        gsub(","," ",$3)
        split($3,ct," ")
        # extract flag value and convert to hex
        sub("Flags=","",ct[2])
        str=sprintf("Flags=%d/0x%03x",ct[2],ct[2])
        sub("Flags=[0-9]*",str,$3)
        # get max and current charge levels
        sub(".*=","",ct[4])
        sub(".*=","",ct[5])
        printf("%s [%.1f%%]\n",tolower($3),100*ct[5]/ct[4])
    }'

# EOF
