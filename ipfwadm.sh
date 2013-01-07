#!/bin/sh
#
# /etc/rc.d/rc.firewall: An example of a semi-STRONG IPFWADM firewall ruleset
#

PATH=/sbin:/bin:/usr/sbin:/usr/bin

# testing, wait a bit then clear all firewall rules.
# uncomment following lines if you want the firewall to automatically
# disable after 10 minutes.
# (sleep 600; \
# ipfwadm -I -f; \
# ipfwadm -I -p accept; \
# ipfwadm -O -f; \
# ipfwadm -O -p accept; \
# ipfwadm -F -f; \
# ipfwadm -F -p accept; \
# ) &

# Load all required IP MASQ modules
#
#   NOTE:  Only load the IP MASQ modules you need.  All current IP MASQ modules
#          are shown below but are commented from loading.

# Needed to initially load modules
#
/sbin/depmod -a

# Supports the proper masquerading of FTP file transfers using the PORT method
#
/sbin/modprobe ip_masq_ftp

# Supports the masquerading of RealAudio over UDP.  Without this module,
#       RealAudio WILL function but in TCP mode.  This can cause a reduction
#       in sound quality
#
#/sbin/modprobe ip_masq_raudio

# Supports the masquerading of IRC DCC file transfers
#
#/sbin/modprobe ip_masq_irc


# Supports the masquerading of Quake and QuakeWorld by default.  This modules is
#   for for multiple users behind the Linux MASQ server.  If you are going to play
#   Quake I, II, and III, use the second example.
#
#   NOTE:  If you get ERRORs loading the QUAKE module, you are running an old
#   -----  kernel that has bugs in it.  Please upgrade to the newest kernel.
#
#Quake I / QuakeWorld (ports 26000 and 27000)
#/sbin/modprobe ip_masq_quake
#
#Quake I/II/III / QuakeWorld (ports 26000, 27000, 27910, 27960)
#/sbin/modprobe ip_masq_quake 26000,27000,27910,27960


# Supports the masquerading of the CuSeeme video conferencing software
#
#/sbin/modprobe ip_masq_cuseeme

#Supports the masquerading of the VDO-live video conferencing software
#
#/sbin/modprobe ip_masq_vdolive


#CRITICAL:  Enable IP forwarding since it is disabled by default since
#
#           Redhat Users:  you may try changing the options in /etc/sysconfig/network from:
#
#                       FORWARD_IPV4=false
#                             to
#                       FORWARD_IPV4=true
#
echo "1" > /proc/sys/net/ipv4/ip_forward


# Dynamic IP users:
#
#   If you get your IP address dynamically from SLIP, PPP, or DHCP, enable this following
#       option.  This enables dynamic-ip address hacking in IP MASQ, making the life 
#       with Diald and similar programs much easier.
#
#echo "1" > /proc/sys/net/ipv4/ip_dynaddr


# Specify your Static IP address here.  
#
#   If you have a DYNAMIC IP address, you need to make this ruleset understand your 
#   IP address everytime you get a new IP.  To do this, enable the following one-line 
#   script.  (Please note that the different single and double quote characters MATTER).  
#
#
#   DHCP users:  
#   -----------
#   If you get your TCP/IP address via DHCP, **you will need ** to enable the #ed out command
#   below underneath the PPP section AND replace the word "ppp0" with the name of your EXTERNAL 
#   Internet connection (eth0, eth1, etc).  It should be also noted that the DHCP server can 
#   change IP addresses on you.  To fix this, users should configure their DHCP client to 
#   re-run the firewall ruleset everytime the DHCP lease is renewed.  
#
#     NOTE #1:  Some newer DHCP clients like "pump" do NOT have this ability to run scripts
#               after a lease-renew.  Because of this, you need to replace it with something
#               like "dhcpcd" or "dhclient".
#
#     NOTE #2:  The syntax for "dhcpcd" has changed in recent versions.
#
#               Older versions used syntax like:
#                         dhcpcd -c /etc/rc.d/rc.firewall eth0
#
#               Newer versions use syntax like:
#                         dhcpcd eth0 /etc/rc.d/rc.firewall
#
#   
#   PPP users:  
#   ----------
#   If you aren't already aware, the /etc/ppp/ip-up script is always run when a PPP 
#   connection comes up.  Because of this, we can make the ruleset go and get the 
#   new PPP IP address and update the strong firewall ruleset.
#
#   If the /etc/ppp/ip-up file already exists, you should edit it and add a line
#   containing "/etc/rc.d/rc.firewall" near the end of the file.
#
#   If you don't already have a /etc/ppp/ip-up sccript, you need to create the following 
#   link to run the /etc/rc.d/rc.firewall script.
#
#       ln -s /etc/rc.d/rc.firewall /etc/ppp/ip-up
#
#   * You then want to enable the #ed out shell command below *
#
#  
# PPP and DHCP Users: 
# -------------------
# Remove the # on the line below and place a # in front of the line after that.
#
#ppp_ip = "`/sbin/ifconfig ppp0 | grep 'inet addr' | awk '{print $2}' | sed -e 's/.*://'`"
#
ppp_ip="your.static.PPP.address"


# MASQ timeouts 
#
#   2 hrs timeout for TCP session timeouts
#  10 sec timeout for traffic after the TCP/IP "FIN" packet is received
#  60 sec timeout for UDP traffic (MASQ'ed ICQ users must enable a 30sec firewall timeout in ICQ itself) 
#
/sbin/ipfwadm -M -s 7200 10 60


#############################################################################
# Incoming, flush and set default policy of reject. Actually the default policy
# is irrelevant because there is a catch all rule with deny and log.
#
/sbin/ipfwadm -I -f
/sbin/ipfwadm -I -p reject

# local interface, local machines, going anywhere is valid
#
/sbin/ipfwadm -I -a accept -V 192.168.0.1 -S 192.168.0.0/24 -D 0.0.0.0/0

# remote interface, claiming to be local machines, IP spoofing, get lost
#
/sbin/ipfwadm -I -a reject -V $ppp_ip -S 192.168.0.0/24 -D 0.0.0.0/0 -o

# remote interface, any source, going to permanent PPP address is valid
#
/sbin/ipfwadm -I -a accept -V $ppp_ip -S 0.0.0.0/0 -D $ppp_ip/32

# loopback interface is valid.
#
/sbin/ipfwadm -I -a accept -V 127.0.0.1 -S 0.0.0.0/0 -D 0.0.0.0/0

# catch all rule, all other incoming is denied and logged. pity there is no
# log option on the policy but this does the job instead.
#
/sbin/ipfwadm -I -a reject -S 0.0.0.0/0 -D 0.0.0.0/0 -o


#############################################################################
# Outgoing, flush and set default policy of reject. Actually the default policy
# is irrelevant because there is a catch all rule with deny and log.
#
/sbin/ipfwadm -O -f
/sbin/ipfwadm -O -p reject

# local interface, any source going to local net is valid
#
/sbin/ipfwadm -O -a accept -V 192.168.0.1 -S 0.0.0.0/0 -D 192.168.0.0/24

# outgoing to local net on remote interface, stuffed routing, deny
#
/sbin/ipfwadm -O -a reject -V $ppp_ip -S 0.0.0.0/0 -D 192.168.0.0/24 -o

# outgoing from local net on remote interface, stuffed masquerading, deny
#
/sbin/ipfwadm -O -a reject -V $ppp_ip -S 192.168.0.0/24 -D 0.0.0.0/0 -o

# outgoing from local net on remote interface, stuffed masquerading, deny
#
/sbin/ipfwadm -O -a reject -V $ppp_ip -S 0.0.0.0/0 -D 192.168.0.0/24 -o

# anything else outgoing on remote interface is valid
#
/sbin/ipfwadm -O -a accept -V $ppp_ip -S $ppp_ip /32 -D 0.0.0.0/0

# loopback interface is valid.
#
/sbin/ipfwadm -O -a accept -V 127.0.0.1 -S 0.0.0.0/0 -D 0.0.0.0/0

# catch all rule, all other outgoing is denied and logged. pity there is no
# log option on the policy but this does the job instead.
#
/sbin/ipfwadm -O -a reject -S 0.0.0.0/0 -D 0.0.0.0/0 -o


#############################################################################
# Forwarding, flush and set default policy of deny. Actually the default policy
# is irrelevant because there is a catch all rule with deny and log.
#
/sbin/ipfwadm -F -f
/sbin/ipfwadm -F -p deny

# Masquerade from local net on local interface to anywhere.
#
/sbin/ipfwadm -F -a masquerade -W ppp0 -S 192.168.0.0/24 -D 0.0.0.0/0
#
# catch all rule, all other forwarding is denied and logged. pity there is no
# log option on the policy but this does the job instead.
#
/sbin/ipfwadm -F -a reject -S 0.0.0.0/0 -D 0.0.0.0/0 -o

#End of file.



With IPFWADM, you can block traffic to a particular site using the -I, -O or -F rules. Remember that the set of rules are scanned top to bottom and "-a" means "append" to the existing set of rules. So with this in mind, any specific restrictions need to come before global rules. For example: 

Using -I rules. Probably the fastest but it only stops the local machines, the firewall itself can still access the "forbidden" site. Of course you might want to allow that combination. 


In the /etc/rc.d/rc.firewall ruleset: 

... start of -I rules ...

# reject and log local interface, local machines going to 204.50.10.13
#
/sbin/ipfwadm -I -a reject -V 192.168.0.1 -S 192.168.0.0/24 -D 204.50.10.13/32 -o

# local interface, local machines, going anywhere is valid
#
/sbin/ipfwadm -I -a accept -V 192.168.0.1 -S 192.168.0.0/24 -D 0.0.0.0/0

... end of -I rules ...


Using -O rules. Slowest because the packets go through masquerading first but this rule even stops the firewall accessing the forbidden site. 


... start of -O rules ...

# reject and log outgoing to 204.50.10.13
#
/sbin/ipfwadm -O -a reject -V $ppp_ip -S $ppp_ip/32 -D 204.50.10.13/32 -o

# anything else outgoing on remote interface is valid
#
/sbin/ipfwadm -O -a accept -V $ppp_ip -S $ppp_ip/32 -D 0.0.0.0/0

... end of -O rules ...

Using -F rules. Probably slower than -I and this still only stops masqueraded machines (i.e. internal), firewall can still get to forbidden site. 


... start of -F rules ...

# Reject and log from local net on PPP interface to 204.50.10.13.
#
/sbin/ipfwadm -F -a reject -W ppp0 -S 192.168.0.0/24 -D 204.50.10.13/32 -o

# Masquerade from local net on local interface to anywhere.
#
/sbin/ipfwadm -F -a masquerade -W ppp0 -S 192.168.0.0/24 -D 0.0.0.0/0

... end of -F rules ...


