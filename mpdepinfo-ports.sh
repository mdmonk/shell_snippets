#!/bin/sh -

# mpdepinfo - print 2 lists of dependents in the following forms
#	1) <port> depends on <port>
#	2) <port> has no dependents!

umask 0077

dir="/tmp/`basename $0`-$$"
fil="$dir/cmdfil"
trap 'rtn=$?; rm -rf $dir; exit $rtn' EXIT
trap 'exit $?' HUP INT QUIT TERM

mkdir "$dir" || exit 2

(
	IFS='
'
	for p in `port installed | sed '1d ; s/^  // ; s/ (active)$//'` ; do
		echo dependents "$p"
	done
) >"$fil"

port -F "$fil" | egrep -v '^$|no dependents' | sort
echo
port -F "$fil" | grep 'no dependents' | sort
