#!/usr/bin/ksh
#
# Enhanced mobile-otp Version 1.0 including the Iphone UDID
# (c) 2010 - Oliver J. Albrecht ASION IT-Services GmbH
# based on:
#
# Mobile One Time Passwords (Mobile-OTP) for Java 2 Micro Edition, J2ME
# written by Matthias Straub, Heilbronn, Germany, 2003
# (c) 2003 by Matthias Straub
#
# Version 1.04c
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
# arguments:  $1 $2 $3 $4 $5 $6
# $1 - username
# $2 - one-time-password that is to be checked 
# $3 - init-secred from token (to init token: #**#)
# $4 - user PIN
# $5 - Iphone UDID
# $6 - time difference between token and server in 10s of seconds (360 = 1 hour)
#
# one-time-password must match md5(EPOCHTIME+SECRET+PIN+UDID)
# 

#
# otpverify.sh version 1.04b, Feb. 2003
# otpverify.sh version 1.04c, Nov. 2008
#  changed line 1 to ksh because of problems with todays bash an sh
#
# otpverify-asion.sh version 1.0 Jan 2010 - O. Albrecht ASION IT-Services GmbH
# - hash includes the iphone UDID
# - cached passwords are now saved in a directory per user
#
# otpverify-asion.sh version 1.01 May 2010  - O. Albrecht ASION IT-Services GmbH
# - added security fixes as suggested by Piotr Zazakowny (http://motp.sourceforge.net/#3)
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

if [ -e "`which md5 2>/dev/null`" ]
then
	alias md5sum=md5
	have_md5="true"
fi
if [ -e "`which md5sum 2>/dev/null`" ]
then
	alias md5sum=md5sum
	have_md5="true"
fi

if [ $have_md5 != "true" ]
then
	echo "No md5 or md5sum available on server!"
	#exit 6
	# security fix, exit code changed
	exit 16
fi

function chop
{
	num=`echo -n "$1" | wc -c | sed 's/ //g' `
	nummin1=`expr $num "-" 1`
	echo -n "$1" | cut -b 1-$nummin1 
}

if [ ! $# -eq 6 ] ; then
echo "USAGE: otpverify.sh Username, OTP, Init-Secret, PIN, UDID, Offset"
#exit 4
# security fix, exit code changed
exit 14
fi

USERNAME=`echo -n "$1" | sed 's/[^0-9a-zA-Z._-]/X/g' `
PASSWD=`echo -n "$2" | sed 's/[^0-9a-f]/0/g' `
SECRET=`echo -n "$3" | sed 's/[^0-9a-f]/0/g' `
PIN=`echo -n "$4" | sed 's/[^0-9]/0/g' `
UDID=`echo -n "$5" | sed 's/[^0-9a-f]/0/g' `
OFFSET=`echo -n "$6" | sed 's/[^0-9]/0/g' `
EPOCHTIME=`date +%s` ; EPOCHTIME=`chop $EPOCHTIME`

mkdir /var/motp-asion 2>/dev/null
mkdir /var/motp-asion/users 2>/dev/null
mkdir /var/motp-asion/users/$USERNAME.cache 2>/dev/null
# chmod og-rxw /var/motp-asion 2>/dev/null || { echo "FAIL! Need write-access to /var/motp-asion"; exit 7; }
# security fix, exit code changed
chmod og-rxw /var/motp-asion 2>/dev/null || { echo "FAIL! Need write-access to /var/motp-asion"; exit 17; }
chmod og-rxw /var/motp-asion/users
chmod og-rxw /var/motp-asion/users/$USERNAME.cache

# delete old logins
find /var/motp-asion/users/$USERNAME.cache -type f -cmin +5 | xargs rm 2>/dev/null

if [ -e "/var/motp-asion/users/$USERNAME.cache/$PASSWD" ]; then
	echo "FAIL"
	#exit 5
        # security fix, exit code changed
	exit 15
fi

# account locked?
if [ "`cat /var/motp-asion/users/$USERNAME 2>/dev/null`" == "8" ]; then
	echo "FAIL"
	#exit 3
	# security fix, exit code changed
	exit 13
fi


I=0
EPOCHTIME=`expr $EPOCHTIME - 18`
EPOCHTIME=`expr $EPOCHTIME + $OFFSET`
while [ $I -lt 36 ] ; do # 3 minutes before and after
	OTP=`printf $EPOCHTIME$SECRET$PIN$UDID|md5sum|cut -b 1-6`
	if [ "$OTP" = "$PASSWD" ] ; then
		# touch /var/motp-asion/users/$USERNAME.cache/$OTP || { echo "FAIL! Need write-access to /var/motp-asion/users/$USERNAME.cache/" ; exit 7; }
		# security fix, exit code changed
		touch /var/motp-asion/users/$USERNAME.cache/$OTP || { echo "FAIL! Need write-access to /var/motp-asion/users/$USERNAME.cache/" ; exit 17; }
		echo "ACCEPT"
		rm "/var/motp-asion/users/$USERNAME" 2>/dev/null
		exit 0
	fi
	I=`expr $I + 1`
	EPOCHTIME=`expr $EPOCHTIME + 1`
done

echo "FAIL"
NUMFAILS=`cat "/var/motp-asion/users/$USERNAME" 2>/dev/null`
if [ "$NUMFAILS" = "" ]; then
	NUMFAILS=0
fi
NUMFAILS=`expr $NUMFAILS + 1`
echo $NUMFAILS > "/var/motp-asion/users/$USERNAME"
# exit 1
# security fix, exit code changed
exit 10

