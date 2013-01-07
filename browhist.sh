#!/bin/sh
# mozhist: save mozilla history for today

PATH=/bin:/usr/bin:/usr/local/bin:$HOME/bin
export PATH
umask 022

# your history file.
##hfile="$HOME/.mozilla/$USER/nwh6n09i.slt/history.dat"
hfile="$HOME/.mozilla/firefox/s2qvfmnj.default/history.dat"

# sed script
sedscr='
  s/\/$//
  /view.atdmt.com/d
  /ad.doubleclick.net/d
  /tv.yahoo.com/d
  /adq.nextag.com\/buyer/d
  /googlesyndication.com/d
  /overture.com/d
'

# remove crap like trailing slashes, doubleclick ads, etc.
set X `date "+%Y %m %d"`
case "$#" in
    4) yr=$2; mo=$3; da=$4 ;;
    *) exit 1 ;;
esac

dest="$HOME/DOCS/notebook/$yr/${mo}${da}"
test -d "$dest" || exit 2

##exec mozilla-history $hfile |           # get history...
##exec $HOME/bin/mork.pl $hfile |         # get history...
exec mork.pl $hfile |         # get history...
   sed -e "$sedscr" |                   # ... strip crap ...
   sort -u |                            # ... remove duplicates ...
   tailocal.pl |              # ... change date to ISO ...
   grep "$yr-$mo-$da" |                 # ... look for today ...
   cut -c12- |                          # ... zap the date ...
   ##cut -f1,3 |                          # ... keep time and URL ...
   cut -f1,2 |                          # ... keep time and URL ...
   expand -1 > $dest/browser-history    # ... and store

exit 0
