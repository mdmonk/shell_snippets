#!/bin/bash
###############
# getStream.sh
# - CWL
# - Runs streamripper, to copy a CDs worth of music from a cool mp3 stream, and saves
# it to disk.
####
# Options:
#  '-r' = creates a proxy/relay on the port specified. if no port specified, then 
#         8000 assumed.
#  '-l' = amount of seconds for streamripper to run. 74min * 60 seconds = 4440 seconds
#         4400 so I have 40 seconds to spare so I can burn it to CD.
#  '-d' = directory to save the stream to.
###############
#while [ -f /tmp/.sripper ] ; do
##while /bin/true; do
#  /usr/local/bin/streamripper http://205.188.234.34:8004 -d /DG/sripper -r -l 4400;
###
# Since I'm no longer looping, and the app rips each track, not one continuous
# stream, I'm just going to let it run mad, as long as it logs to:
# /var/log/sripper.log.   =)  CWL 5/29/2001
###
  /usr/local/bin/streamripper http://205.188.234.34:8004 -d /DG/sripper -r 2>&1 > /var/log/sripper.log
#done
