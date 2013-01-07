#!/bin/sh

#------------------------------------------------------------------------------
# router.sh - Router monitoring sript
# Copyright (C) 2000 Mayur R. Naik

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

#------------------------------------------------------------------------------

#------------------ README -----------------------------------------------------
#
# This script allows easy monitoring of SNMP-manageable routers.
# It's based on ucd-snmp-utils (snmpwalk) and gawk
# You can contact the author at mayur@arya.ncst.ernet.in

#------------------ PARSE COMMANDLINE ------------------------------------------

if [ $# -eq 0 ] 
then
	echo "[01;31mUsage: `basename $0` <name> <cmty>[0m"
	exit
fi

# First argument is name or ip addr of router
host=$1

# Second argument is community name
if [ x$2 = x ]
then
	cmty=public
else
	cmty=$2
fi

#------------------ QUERY SNMP VARIABLES ---------------------------------------

snmpwalk -s $host $cmty interfaces.ifTable.ifEntry.ifDescr >> /tmp/s$$
snmpwalk -s $host $cmty interfaces.ifTable.ifEntry.ifAdminStatus >> /tmp/s$$
snmpwalk -s $host $cmty interfaces.ifTable.ifEntry.ifOperStatus >> /tmp/s$$
snmpwalk -s $host $cmty interfaces.ifTable.ifEntry.ifInOctets >> /tmp/s$$
snmpwalk -s $host $cmty interfaces.ifTable.ifEntry.ifOutOctets >> /tmp/s$$
snmpwalk -s $host $cmty ifMIB.ifMIBObjects.ifXTable.ifXEntry.ifAlias >> /tmp/s$$
snmpwalk -s $host $cmty system.sysName >> /tmp/s$$
echo "END0012" >> /tmp/s$$
cnt=`snmpwalk -s $host $cmty interfaces.ifNumber | cut -d ' ' -f 3`

#------------------ OUTPUT FORMATTING IN AWK -----------------------------------

i=0
while [ $i -le $cnt ]
do
awk -F= "\
/Name\.$i\>/		{\
printf \"%-49s %29s\n\", \$2, strftime(\"%c\"); as=\"z\"; os=\"z\";\
printf \"[01;37m\
___Interface_|_Stat_|_____InOctets_|____OutOctets_|_Description________________\
[0m\n\"};
/Descr\.$i\>/		{ de=substr(substr(\$2,3,length(\$2)-3), 0, 12)};\
/AdminStatus\.$i\>/ 	{ as=substr(\$2, 2, 1)};\
/OperStatus\.$i\>/ 	{ os=substr(\$2, 2, 1)};\
/InOctets\.$i\>/	{ i=\$2};\
/OutOctets\.$i\>/ 	{ o=\$2};\
/ifAlias\.$i\>/ 	{ al=substr(\$2, 2, 27)};\
/END0012/		{ \
if (as==\"d\") \
printf \" %11s |  N/C | %12d | %12d | %s\n\", de, i, o, al;\
else if (os==\"d\") \
printf \" %11s | [01;31mdown[0m | %12d | %12d | %s\n\", de, i, o, al;\
else if (os==\"u\") \
printf \" %11s | [01;32m  up[0m | %12d | %12d | %s\n\", de, i, o, al;\
else if (os==\"t\") \
printf \" %11s | [01;33mtest[0m | %12d | %12d | %s\n\", de, i, o, al};\
" /tmp/s$$ >> /tmp/r$$
i=`expr $i + 1`
done

#------------------ CLEANUP ----------------------------------------------------

cat /tmp/r$$
rm /tmp/r$$
rm /tmp/s$$
