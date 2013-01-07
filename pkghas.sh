#!/bin/bash
#############
# this lists the files, etc, a pkg installs. 
# $1 is supposed to be the pkg name that is passed
# in to the script. Is $1 the correct var to use for
# shell prgming? -CWL
#############
# /usr/bin/lsbom /Library/Receipts/<package>/Contents/Archive.bom
/usr/bin/lsbom /Library/Receipts/$1/Contents/Archive.bom

