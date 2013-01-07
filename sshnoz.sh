#!/bin/sh
#
# sshnoz.sh
#
# $Id$
#
# Invoke ssh without compression (which is enabled by default
# in my configurations).  We need this wrapper script for things
# like cvs and rsync which will use ssh as their rsh-alternative
# but have difficulty with ssh arguments.
#
exec /usr/bin/ssh -o "Compression no" $*
