#!/bin/bash
# I once used TCP raw flags from octet 13 of the TCP header:
#
# CWR | ECE | URG | ACK | PSH | RST | SYN | FIN
# 128 |  64 |  32 |  16 |   8 |   4 |   2 |   1
# like tcp[13]=1 was a fin....
#
# now, i use something like tcp[tcpflags]==tcp-fin
#
# johnny@ihackstuff.com

test $USER != root && echo "You gotta be root!" && exit
test $# -ne 5 && echo && \

echo "This script looks for a trigger packet and then creates temporary" &&\
echo "firewall block on your machine." && \
echo && \
echo "You must first set the trigger packet (src_ip, dst_ip, detect_flag)" &&\
echo "then set the types of packets you want to block (drop_flag) to that IP." &&\
echo "Last, you must set the time the rule should stick." &&\
echo &&\
echo "Examples:" &&\
echo "detectwall 10.6.20.114 fin 10.6.20.106 fin 5" &&\
echo "   This locates FIN packets from .114 to .106, then blocks more outbound FINs." &&\
exit

src=$1
detect_flag=$2
dst=$3
drop_flag=$4
time=$5


tcpdump -c 1 src $src and dst $dst and  tcp[tcpflags]==tcp-$detect_flag && ipfw add 1010 drop tcp from me to $dst out tcpflags $drop_flag 
echo "--==[ Firewall Rule Set! ]==--"
ipfw show 1010
echo "--==[      Sleeping...   ]==--"
sleep $time
ipfw del 1010
echo "--==[ Resetting Firewall ]==--"
ipfw show

