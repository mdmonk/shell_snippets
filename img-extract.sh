#!/bin/sh
# $Id$
# Extract <IMG> tags from plaintext file.  Primitive.  Assumes ony one
# <IMG> tag is on each line, which is dumb.

if [ -z "$1" ]; then
	echo "Need a filename as first argument."
	exit 1
fi

if [ ! -r "$1" ]; then
	echo "Can't read/open file."
	exit 1
fi

if [ "$2" != "listing" ]; then
	sed 's/^.*\(<[Ii][Mm][Gg][^>]*>\).*$/\1/' "$1"
else
	
fi
