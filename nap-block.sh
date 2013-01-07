#!/bin/bash

/sbin/ipchains -A output -p tcp -d 0.0.0.0/32 4444 -j DENY -l
/sbin/ipchains -A output -p udp -d 0.0.0.0/32 4444 -j DENY -l
/sbin/ipchains -A output -p tcp -d 0.0.0.0/32 5555 -j DENY -l
/sbin/ipchains -A output -p udp -d 0.0.0.0/32 5555 -j DENY -l
/sbin/ipchains -A output -p tcp -d 0.0.0.0/32 6666 -j DENY -l
/sbin/ipchains -A output -p udp -d 0.0.0.0/32 6666 -j DENY -l
/sbin/ipchains -A output -p tcp -d 0.0.0.0/32 7777 -j DENY -l
/sbin/ipchains -A output -p udp -d 0.0.0.0/32 7777 -j DENY -l
/sbin/ipchains -A output -p tcp -d 0.0.0.0/32 8888 -j DENY -l
/sbin/ipchains -A output -p udp -d 0.0.0.0/32 8888 -j DENY -l
