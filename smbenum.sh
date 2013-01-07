#!/bin/bash

#
# $Id: smbenum,v 1.2 2006/12/05 09:04:02 raptor Exp $
#
# smbenum v0.1 - remote users enumeration script via smb
# Copyright (c) 2006 Marco Ivaldi <raptor@0xdeadbeef.info>
#
# Based on samba-tng's rpcclient (http://www.samba-tng.org/).
#
# Usage example: ./smbenum hosts.txt
#

# Some vars
rpcclient=/usr/local/samba/bin/rpcclient

# Command line
filename=$1

function usage() {
	echo ""
	echo "smbenum v0.1 - remote users enumeration script via smb"
	echo "Copyright (c) 2006 Marco Ivaldi <raptor@0xdeadbeef.info>"
	echo ""
	echo "usage  : ./smbenum <filename>"
	echo "example: ./smbenum hosts.txt"
	echo ""
	exit 1
}

# Input control
if [ -z "$1"  ]; then
	usage
fi

if [ "`cat $filename 2>/dev/null`" = "" ]; then
	echo "err: corrupted hosts file?"
	exit 1
fi

# Perform the scan
for current in `cat $filename`
do
	echo "[${current}]"
	$rpcclient -S $current -U '%' -c enumusers | grep "(" | grep -v OpenConfFile | grep -v connec | grep -v FAILED
done

exit 0
