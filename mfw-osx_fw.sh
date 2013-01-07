#!/bin/sh
#
# $Id: mfw,v 1.20 2004/01/22 19:27:33 jmates Exp $
#
# The author disclaims all copyrights and releases this document into
# the public domain.
#
# Allows use of multiple firewall configurations on Mac OS X.
#
# http://sial.org/howto/osx/firewall/
#
########################################################################
#
# CONSTANTS

# preferences dir for this utility
MFWETC=/etc/mfw

# custom env definitions file; put localizations in the MFWRC file
# instead of altering this script if possible
MFWRC=$MFWETC/mfwrc

# custom env for the mode scripts
MFWMODERC=$MFWETC/moderc

# dir for holding different firewall modes
MFWMODES=$MFWETC/modes

# where to store vendor default rule(s)
# Apple sets '65535 allow ip from any to any' by default, but that
# could change.
MFWVENDORRULES=$MFWETC/vendor-rules

# short application name of us
mfw=`basename $0`

# how to call various apps
ipfw="/sbin/ipfw -q"
natd="/usr/sbin/natd"
sysctl="/usr/sbin/sysctl"

VERBOSE=0

########################################################################
#
# SUBROUTINES

# creates required supporting areas, initial firewall modes
init () {
  _makedir $MFWETC $MFWMODES

  active2mode "default"
  startup "default"
  current "default"

  # create vendor default ruleset
  shellheader $MFWMODES/vendor
  echo '$ipfw -f flush' >> $MFWMODES/vendor
  shellfooter $MFWMODES/vendor
  chmod +x $MFWMODES/vendor
}

# removes this utility from system
uninit () {
  _removedir $MFWMODES $MFWETC
}

_makedir () {
  mkdir -p $@
  RETURN=$?
  if [ $RETURN -ne 0 ]; then
    echo "error creating required directories" >&2
    exit $RETURN
  fi
}

_removedir () {
  rm -rf $@
  RETURN=$?
  if [ $RETURN -ne 0 ]; then
    echo "error removing required directories" >&2
    exit $RETURN
  fi
}

# writes active IPFW ruleset (minus dynamic and vendor default) to
# mode file
active2mode () {
  if [ $VERBOSE -eq 1 ]; then
    echo "${mfw} info: creating new mode $1 from current state"
  fi

  # whether ruleset reload is needed
  RELOAD=0

  # mktemp added in OS X 10.2, compile and install on 10.1 if needed
  TMPFILE=`mktemp -q /tmp/${mfw}.XXXXXX`
  if [ $? -ne -0 ]; then
    echo "${mfw} error: could not create temp file" >&2
    exit 1
  fi

  $ipfw list > $TMPFILE

  # remove dynamic rules
  if grep '^#' $TMPFILE > /dev/null; then
    perl -i -nle 'print $last and $last=$_ if 1../^#/' $TMPFILE
  fi

  # save vendor defaults so can remove them from regular listing
  if [ ! -f $MFWVENDORRULES ]; then
    $ipfw flush
    $ipfw list > $MFWVENDORRULES
    RELOAD=1
  fi

  # remove vendor default rule(s) from listing as otherwise will see
  # 'getsockopt(IP_FW_ADD): Invalid argument' errors
  perl -i -nle 'BEGIN { $rf = shift; open RF, $rf; chomp(@r=<RF>); }' \
   -e '$l = $_; print $l unless grep { -1 < index($l, $_) ? 1 : 0 } @r' \
   $MFWVENDORRULES $TMPFILE

  # turn ipfw list output into shell script
  shellheader $MFWMODES/$1

  perl -i -ple 's/^/\$ipfw add /' $TMPFILE
  cat $TMPFILE >> $MFWMODES/$1

  shellfooter $MFWMODES/$1

  chmod +x $MFWMODES/$1

  if [ $RELOAD -eq 1 ]; then
    runmode $1 start
  fi

  if grep divert $TMPFILE > /dev/null; then
    echo "${mfw} notice: ruleset $1 appears to support NAT" >&2
    echo "  natd setup must be manually added to mode script." >&2
  fi

  # OS X 10.2 does not appear to support pipe/queue as the FreeBSD ipfw
  # does (despite man page indicating otherwise); if did, would need to
  # do 'ipfw pipe list' and 'ipfw queue list' and figure out how to get
  # that information into the mode file.

  # cleanup
  rm $TMPFILE
}

# runs mode script for named mode
runmode () {
  if [ ! -e $MFWMODES/$1 ]; then
    echo "${mfw} error: no such mode: $1" >&2
    exit 1
  fi

  if [ -x $MFWMODES/$1 ]; then
    # stop prior config, if any and starting anew
    if [ $2 = "start" ]; then
      if [ -x $MFWMODES/cur ]; then
        runmode cur stop
      fi
    fi

    if [ $VERBOSE -eq 1 ]; then
      if [ -L $1 ]; then
        echo "${mfw} info: running $1 (`perl -le 'print readlink shift' $1`) $2"
      else
        echo "${mfw} info: running $1 $2"
      fi
    fi

    if [ $2 = "start" ]; then
      current $1
    fi
    if [ $1 = "pre" -a $2 = "start" ]; then
      MFWMODENAME=`perl -le 'print readlink shift' $MFWMODES/cur`
      MFWMODEPATH=$MFWMODES/$MFWMODENAME
      . $MFWMODES/cur $2
    else
      if [ -L $1 ]; then
        MFWMODENAME=`perl -le 'print readlink shift' $MFWMODES/cur`
      else
        MFWMODENAME=$1
      fi
      MFWMODEPATH=$MFWMODES/$MFWMODENAME
      . $MFWMODES/$1 $2
    fi
  else
    echo "${mfw} error: could not run mode: $1" >&2
    exit 1
  fi
}

# creates a link to a mode a script running from StartupItems can use
startup () {
  (
    cd $MFWMODES

    if [ ! -e $1 ]; then
      echo "${mfw} error: no such mode $1" >&2
      exit 1
    fi

    ln -sf $1 startup
  )
}

# link to current mode (for restarts, keeping previous for reversions)
current () {
  (
    cd $MFWMODES
    if [ $1 = "cur" ]; then
      return
    elif [ $1 = "startup" ]; then
      # do not update pointers for system startup
      if ! test -t 0; then
        return
      fi
    fi
    if [ -L cur ]; then
      if [ $1 = "pre" ]; then
        mv pre .tmp
        mv cur pre
        mv .tmp cur
      elif [ `perl -le 'print readlink shift' cur` != "$1" ]; then
        mv cur pre
        ln -s $1 cur
      fi
    elif [ ! -e cur ]; then
      ln -s $1 cur
    else
      echo "${mfw} error: cur mode not a symbolic link"
      exit 1
    fi
  )
}

# how all mode script should start out
# be sure to \escape variables  if you do not want them expanded
shellheader () {
  cat <<EOF >> $1
#!/bin/sh

if [ -f \$MFWMODERC ]; then
  . \$MFWMODERC
fi

OPMODE=\$1
OPMODE=\${OPMODE:=start}

case "\$OPMODE" in
  start)

EOF
}

# complete mode script (disallows custom 'stop' code)
# be sure to \escape variables  if you do not want them expanded
shellfooter () {
  cat <<EOF >> $1

  ;;
  restart)

  \$0 stop
  \$0 start

  ;;
  stop)

  \$ipfw -f flush

  ;;
esac
EOF
}

# lists available modes
list () {
  (
    cd $MFWMODES
    ls * | grep -v '\.' | while read mode; do
      if [ ! -L $mode ]; then
        echo $mode
      fi
    done
  )
}

listall () {
  (
    cd $MFWMODES
    ls * | grep -v '\.' | while read mode; do
      if [ ! -L $mode ]; then
        echo $mode
      else
        perl -le '$m=shift; print "$m -> ", readlink $m' $mode
      fi
    done
  )
}

########################################################################
#
# MAIN

if [ `id -u` != 0 ]; then
  echo "${mfw} error: must be run as superuser"
  exit 1
fi

if [ -f $MFWRC ]; then
  . $MFWRC
  if [ $? -ne 0 ]; then
    echo "${mfw} error: could not load ${MFWRC}"
    exit 1
  fi
fi

if [ ! -d $MFWETC -o ! -d $MFWMODES ]; then
  echo "${mfw} notice: configuration not found, building from scratch" >&2
  init
  exit
fi

OPT=
while getopts lmnsv OPT; do
  case $OPT in
    l)
      list
      exit
    ;;
    m)
      listall
      exit
    ;;
    n)
      shift
      if [ ! -e $MFWMODES/$1 ]; then
        active2mode $1
      else
        echo "${mfw} error: mode $1 already exists" >&2
      fi
      exit
    ;;
    s)
      shift
      startup $1
      exit
    ;;
    v)
      shift
      VERBOSE=1
    ;;
  esac
done

# default to loading current ruleset
WHAT=
WHAT=$1
WHAT=${WHAT:=cur}

HOW=
if echo $2 | egrep '^(start|stop|restart)$' > /dev/null; then
  HOW=$2
else
  HOW=start
fi

runmode $WHAT $HOW

exit 0
