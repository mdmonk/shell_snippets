#!/bin/ksh
# Created by Ben Okopnik on Mon Apr  1 04:12:39 EST 2002

line=$(($RANDOM%`grep -c '$' /home/ballard/bofhserver/excuses`))

cat << !
=== The BOFH-style Excuse Server --- Feel The Power!
=== By Jeff Ballard <ballard@cs.wisc.edu>
=== See http://www.cs.wisc.edu/~ballard/bofh/ for more info.
!

cat -n /home/ballard/bofhserver/excuses|while read a b
do
    [ "$a" = "$line" ] && { echo "Your excuse is: $b"; break; }
done

