#!/bin/ksh
#
# ftp-rpc-probe.sh
#
# Detect potential RPC services listening on filtered ports,
# using duke's funny PASV probing technique. ^_^
#
# This requires that the target allocates its ports in monotonically
# increasing order - this doesn't work against OpenBSD!
#  
# Dug Song <dugsong@monkey.org>
 
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin

function usage {
    echo "Usage: ftp-rpc-probe [-v] [-z] <host>" >&2; exit 1
}

function vprint {
    if [ "x$verbose" != "x" ]; then print "$1" >&2; fi
}

while getopts vz opt 2>&-; do
    case "$opt" in
	v) verbose=1 ;;
	z) closeports=1 ;;
	\?) usage ;;
    esac
done

shift $(($OPTIND - 1))

if [ $# -ne 1 ]; then usage; fi

trap 'echo "connection closed" >&2; exit 0' 0 1 2 3 13 15

host=$1

nc $host 21 |&

if [ "x$closeports" != "x" ]; then
    closeport="nc -z $host"
else
    closeport=:
fi

while read -p line; do
    vprint "$line"; set -- $line
    if [ "$1" = "220" ]; then break; fi
done

print -p "USER anonymous\r"
read -p line; vprint "$line"; set -- $line
if [ "$1" = "530" ]; then
    echo "anonymous login denied" >&2
    exit 1
fi

print -p "PASS mozilla@\r"
while read -p line; do
    vprint "$line"; set -- $line
    if [ "$1" = "230" ]; then break; fi
done

IFS="(,) "
oport=0

while true; do
    print -p "PASV\r"
    read -p line; vprint "$line"; set -- $line

    if [ "$1" != "227" ]; then break; fi

    shift $(($# - 3))
    port=$(($1 * 256 + $2))

    if [ $oport -ne 0 ] && [ $port -lt $oport ]; then break; fi

    if [ $(($port - $oport)) -gt 1 ]; then
	echo "bound port: $(($port - 1))"
    fi

    $closeport $port

    oport=$port
done

exit 0

# 5000.
