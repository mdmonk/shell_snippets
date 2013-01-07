#!/bin/ksh
#
# $Id: mail-summary,v 1.2 2000/07/05 20:16:59 vogelke Exp $
# $Source: /space/home/vogelke/cliche/awk/RCS/mail-summary,v $
#
# NAME:
#    mail-summary
#
# SYNOPSIS:
#    mail-summary [-v] [mail-folder]
#
# DESCRIPTION:
#    Prints a short summary of messages in a mail folder.
#    The default folder is your inbox.
#
# OPTIONS:
#    "-v" prints the version and exits.
#
# AUTHOR:
#    Karl Vogel <vogelke@pobox.com>
#    Sumaria Systems, Inc.

PATH=/bin:/usr/bin
export PATH

tmp=/tmp/mail-summary.$RANDOM.$$
trap "rm -f $tmp; exit 1" ERR	# ksh variants only
umask 022
tag=`basename $0`

# ======================== FUNCTIONS =============================
# die: prints an optional argument to stderr and exits.
#   A common use for "die" is with a test:
#       test -f /etc/passwd || die "no passwd file"
#   This works in subshells and loops, but may not exit with
#   a code other than 0.

die () {
    echo "$tag: ERROR -- $*" >& 2
    exit 1
}

# usage: prints an optional string plus part of the comment
# header (if any) to stderr, and exits with code 1.

usage () {
    lines=`egrep -n '^# (NAME|AUTHOR)' $0 | cut -f1 -d:`

    (
        case "$#" in
            0)  ;;
            *)  echo "usage error: $*"; echo ;;
        esac

        case "$lines" in
            "") ;;

            *)  set `echo $lines | sed -e 's/ /,/'`
                sed -n ${1}p $0 | sed -e 's/^#//g' |
                    egrep -v AUTHOR:
                ;;
        esac
    ) >& 2

    exit 1
}

# version: prints the current version to stdout.

version () {
    lsedscr='s/RCSfile: //
    s/.Date: //
    s/,v . .Revision: /  v/
    s/\$//g'

    lrevno='$RCSfile: mail-summary,v $ $Revision: 1.2 $'
    lrevdate='$Date: 2000/07/05 20:16:59 $'
    echo "$lrevno $lrevdate" | sed -e "$lsedscr"
}

# ======================== MAIN PROGRAM ==========================
# Handle command line arguments.

while getopts v c
do
    case $c in
        v)  version; exit 0 ;;
        \?) usage "invalid argument" ;;
    esac
done
shift `expr $OPTIND - 1`

case "$#" in
    0)  file=$MAIL ;;
    *)  file=$1 ;;
esac

test -f "$file" || die "$file: not found"

#
# Awk script starts here.
#

nawk '
    BEGIN {
        fmt = "%-20.20s  %-25.25s  %-30.30s\n"
        dashes = "--------------------------"
        printf fmt, "From", "Date", "Subject"
        printf fmt, dashes, dashes, dashes
    }

    /^From /  {
        s = substr ($0, 6)
        k = index (s, " ")
        time = substr (s, k+1)
    }

    /^From: /  {
        from = substr ($0, 7, 20)
    }

    /^From:.*\(.*\)/  {
        start = index ($0, "(") + 1
        end = index ($0, ")")
        from = substr ($0, start, end - start)
    }

    /^From:.*\<.*\>/  {
        gsub ("<.*>","")
        from = substr ($0, 7, 20)
    }

    /^Date: /  {
        x = substr ($0, 7)
        gsub ("^ *", "", x)
        time = substr (x, 0, 25)
    }

    /^Subject: /  {
        subj = substr ($0, 10, 30)
        gsub ("^ *", "", subj)
    }

    /^$/ {
        if (length (from) > 0)
        {
            gsub ("\"", "", from)
            gsub (" *$", "", from)
            printf fmt, from, time, subj
            from = ""
        }
    }
' $file

exit 0
