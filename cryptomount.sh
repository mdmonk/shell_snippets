#!/bin/bash
#
# cryptomount - Reads /etc/cryptotab and uses losetup to mount cryptoloop encrypted filesystems
#
# Based on the /etc/init.d/boot.crypto SysV Init script shipped with SUSE LINUX
#  written by: Werner Fink <werner@suse.de>, 2001
#  Copyright (c) 2001-2002 SuSE Linux AG, Nuernberg, Germany.
#  Licensed under the GNU Genral Public License
#
# By: Lamont R. Peterson <lpeterson@gurulabs.com>
# Copyright (c) 2005 Guru Labs, L.C., Bountiful, Utah, USA.
# Licensed under the GNU General Public License
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.

#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the
#  Free Software Foundation, Inc.,
#  59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

trap "echo" SIGINT SIGSEGV
set +e

# Redirect to real device (for boot logging)
: ${CRYPTOTAB:=/etc/cryptotab}
: ${TIMEOUT:=120}
: ${LOSETUP:=/sbin/losetup}
if test -z "$REDIRECT" ; then
	if (echo -n > /dev/tty) 2>/dev/null ; then
		REDIRECT=/dev/tty
	else
		REDIRECT=/dev/console
	fi
fi
test -s $CRYPTOTAB || exit 0
type -p $LOSETUP &> /dev/null || exit 0

# Load cryptoloop module
/sbin/modprobe cryptoloop

otty=`stty -g`
stty $otty < $REDIRECT
stty -nl -ixon ignbrk -brkint < $REDIRECT

while read loopdev physdev mountpoint filesys crypto mopt therestofthefile ; do
	case "$loopdev" in
		\#*|"")
			continue
			;;
	esac
	# Load the specified crypto modules
	case "$crypto" in
		twofish*)
			modprobe loop_fish2
			;;
		aes*)
			modprobe aes
	esac
	test $? -ne 0 && continue
	while true; do
		# Restore virgin state
		$LOSETUP -d $loopdev &> /dev/null || true
		
		# Setting up loop device
		echo "Please enter passphrase for $physdev"
		$LOSETUP -e $crypto $loopdev $physdev < $REDIRECT > $REDIRECT 2>&1
		test $? -ne 0 && continue 2
		
		# Check for success
		if mount -t $filesys -n -o ro $loopdev $mountpoint &> /dev/null ; then
			umount -n $mountpoint &> /dev/null || true
			break
		else
			umount -n $mountpoint &> /dev/null || true
			echo "An error occured.  Maybe the wrong passphrase was"
			echo "entered or the file system on $physdev is corrupted."

			while true ; do
			echo -n "Do you want to retry entering the passphrase ...?"
			read -p " ([yes]/no) " prolo < $REDIRECT
			case "$prolo" in
				[yY][eE][sS]|"")
					continue 2
					;;
				[nN][oO])
					break 2
					;;
			esac
			done
		fi
		break
	done
	# Check for valid super blocks
	case "$filesys" in
		ext2)
			tune2fs -l $loopdev &> /dev/null
			;;
		reiserfs)
			debugreiserfs $loopdev &> /dev/null
			;;
		*)
			true
			;;
	esac
	if test $? -gt 0 ; then
		$LOSETUP -d $loopdev &> /dev/null
		continue
	fi
	
	# Checking the structure on the loop device
	fsck -a -t $filesys $loopdev
	FSCK_RETURN=$?
	test $FSCK_RETURN -lt 2
	if test $FSCK_RETURN -gt 1; then
		echo "fsck of $loopdev failed.  Please repair manually."
		echo "WARNING: NEVER try to repair if you have entered the wrong passphrase!"
		PS1="(repair filesystem) # "
		/sbin/sulogin $REDIRECT < $REDIRECT > $REDIRECT 2>&1
		sync
	fi

	# Mounting loop device to mount point WITHOUT entry in /etc/mtab
	case "$mopt" in
		default|"")
			mopt=""
			;;
	esac
	mount -t $filesys -n ${mopt:+-o $mopt} $loopdev $mountpoint

	if test $? -gt 0 ; then
		$LOSETUP -d $loopdev &> /dev/null
	else
		# Generate entry in /etc/mtab (to enable umount to run $LOSETUP -d)
		loopopt="loop=${loopdev},encryption=${crypto}"
		case "$mopt" in
			default|"")
				mopt="${loopopt}"
				;;
			*)
				mopt="${loopopt},${mopt}"
				;;
		esac
		mount -t $filesys -f -o $mopt $physdev $mountpoint
	fi
done < $CRYPTOTAB
stty $otty < $REDIRECT

