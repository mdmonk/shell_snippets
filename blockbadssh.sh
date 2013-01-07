#!/bin/sh
#
IPFW=/sbin/ipfw
MYIPS=`ifconfig | fgrep inet | fgrep netmask | awk '{print $2}'`
if [ "$MYIPS" = "" ]
then
  exit 1
fi
#
#if [ "$1" = "" ]
#then
#  LOG=/var/log/system.log
#else
#  LOG="$@"
#fi

zgrep -i Illegal /var/log/system.log*gz | fgrep sshd | awk '{print $NF}' | sort | uniq > /tmp/iplist

###
# A different temp file solution from a different person. CWL
###
#TMPFILE=`mktemp /tmp/example.XXXXXXXXXX` || exit 1
#trap "rm -f $TMPFILE" 0 1 2 13 15
#zgrep -i Illegal /var/log/system.log*gz | fgrep sshd | awk '{print $NF}' | sort | uniq > $TMPFILE
###

touch /etc/blacklist
cat /tmp/iplist /etc/blacklist | sort | uniq > /etc/blacklist.new
if [ -s /etc/blacklist.new ]
then
  mv /etc/blacklist.new /etc/blacklist
else
  rm -f /etc/blacklist.new
fi
rm -f /tmp/iplist
chmod og-rwx /etc/blacklist

IPS=`cat /etc/blacklist`

for ip in $IPS
do
  if [ "echo $MYIPS | fgrep $ip" != "" ]
  then
    rules=`/sbin/ipfw show | fgrep $ip | awk '{print $1}'`
    if [ "$rules" != "" ]
    then
      for rul in $rules
      do
        /sbin/ipfw delete $rul
        echo "/sbin/ipfw delete $rul"
      done
    fi
    /sbin/ipfw add deny log ip from $ip to any
  fi
done

