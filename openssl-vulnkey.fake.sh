#!/bin/sh

########################################
#
# openssl-vulnkey.fake.sh --- Fake openssl-vulnkey
#                             All tested keys will be found compromised :)
#
# Copyright (C) 2008 Cedric Blancher <sid@rstack.org>
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation; version 2.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
#########################################


OPENSSL=/usr/bin/openssl

AWK=/usr/bin/awk
SED=/bin/sed

echo "COMPROMISED: "`$OPENSSL x509 -in $1 -noout -fingerprint | $AWK -F "=" '{print $2}' | $SED -e 's/.*/\L&/' -e 's/\://g'`" "$1
