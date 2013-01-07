#!/bin/sh
# showhfs.sh for Mac OS X
# Invoke with one or more filesystem names or devices as parameters
# and those that are hfs will be printed.
df="/bin/df -t hfs"
grep="/usr/bin/grep -qE"

for arg in $*; do
	if [ ! -d $arg -a ! -b $arg ]; then
		echo "Not a directory or block device: $arg"
	else
		$df|$grep "[[:space:]]+$arg$" && echo "$arg is HFS"
	fi
done

