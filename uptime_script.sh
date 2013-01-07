#!/bin/bash

echo >> $1
echo >> $1
top -l1 | head -n 1 | awk '{print $1,$2}' >> $1
echo "<br />" >> $1
uptime | awk '{sub(/.*averages: */,"",$0); print "Averages: "$0}' >> $1
echo "<br />" >> $1
uptime | awk '{sub(/.*up[ ]+/,"",$0) ; sub(/,[ ]+[0-9]+ user.*/,"",$0);sub(/,/,"",$0) ;print "Uptime: "$0}' >> $1
echo "Done!"
