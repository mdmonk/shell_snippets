#!/bin/bash
#
# Mobile One Time Passwords (Mobile-OTP) for Java 2 Micro Edition, J2ME
# written by Matthias Straub, Heilbronn, Germany, 2003
# (c) 2003 by Matthias Straub
#
# Version 1.05a
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Library General Public
# License as published by the Free Software Foundation; either
# version 2 of the License, or (at your option) any later version.
# 
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Library General Public License for more details.
#
# arguments:  $1 $2 $3 $4 $5
# $1 - username
# $2 - one-time-password that is to be checked 
# $3 - init-secred from token (to init token: #**#)
# $4 - user PIN
# $5 - time difference between token and server in 10s of seconds (360 = 1 hour)
#
# one-time-password must match md5(EPOCHTIME+SECRET+PIN)
# 

#
# otpverify.sh version 1.04b, Feb. 2003
# otpverify.sh version 1.04c, Nov. 2008
#  changed line 1 to ksh because of problems with todays bash an sh
# otpverify.sh version 1.05a, Jan. 2011
#  changed back to bash and added in shopts line to ensure aliases handled
#  correctly (bash is always available on any modern *nix unlike ksh)
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

# ensure aliases are expanded by bash
shopt -s expand_aliases

if [ -e "`which md5 2>/dev/null`" ]
then
	alias checksum=md5
	have_md5="true"
fi
if [ -e "`which md5sum 2>/dev/null`" ]
then
	alias checksum=md5sum
	have_md5="true"
fi

if [ $have_md5 != "true" ]
then
	echo "No md5 or md5sum available on server!"
	exit 6
fi

function chop
{
	num=`echo -n "$1" | wc -c | sed 's/ //g' `
	nummin1=`expr $num "-" 1`
	echo -n "$1" | cut -b 1-$nummin1 
}

if [ ! $# -eq 5 ] ; then
echo "USAGE: otpverify.sh Username, OTP, Init-Secret, PIN, Offset"
exit 4
fi

mkdir /var/motp 2>/dev/null
mkdir /var/motp/cache 2>/dev/null
mkdir /var/motp/users 2>/dev/null
chmod og-rxw /var/motp 2>/dev/null || { echo "FAIL! Need write-access to /var/motp"; exit 7; }
chmod og-rxw /var/motp/cache
chmod og-rxw /var/motp/users

USERNAME=`echo -n "$1" | sed 's/[^0-9a-zA-Z._-]/X/g' `
PASSWD=`echo -n "$2" | sed 's/[^0-9a-f]/0/g' `
SECRET=`echo -n "$3" | sed 's/[^0-9a-f]/0/g' `
PIN=`echo -n "$4" | sed 's/[^0-9]/0/g' `
OFFSET=`echo -n "$5" | sed 's/[^0-9]/0/g' `
EPOCHTIME=`date +%s` ; EPOCHTIME=`chop $EPOCHTIME`

# delete old logins
find /var/motp/cache -type f -cmin +5 | xargs rm 2>/dev/null

if [ -e "/var/motp/cache/$PASSWD" ]; then
	echo "FAIL"
	exit 5
fi

# account locked?
if [ "`cat /var/motp/users/$USERNAME 2>/dev/null`" == "8" ]; then
	echo "FAIL"
	exit 3
fi

I=0
EPOCHTIME=`expr $EPOCHTIME - 18`
EPOCHTIME=`expr $EPOCHTIME + $OFFSET`
while [ $I -lt 36 ] ; do # 3 minutes before and after
	OTP=`printf $EPOCHTIME$SECRET$PIN|checksum|cut -b 1-6`
	if [ "$OTP" = "$PASSWD" ] ; then
		touch /var/motp/cache/$OTP || { echo "FAIL! Need write-access to /var/motp" ; exit 7; }
		echo "ACCEPT"
		rm "/var/motp/users/$USERNAME" 2>/dev/null
		exit 0
	fi
	I=`expr $I + 1`
	EPOCHTIME=`expr $EPOCHTIME + 1`
done

echo "FAIL"
NUMFAILS=`cat "/var/motp/users/$USERNAME" 2>/dev/null`
if [ "$NUMFAILS" = "" ]; then
	NUMFAILS=0
fi
NUMFAILS=`expr $NUMFAILS + 1`
echo $NUMFAILS > "/var/motp/users/$USERNAME"
exit 1
