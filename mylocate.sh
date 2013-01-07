#!/bin/sh

# locate - search the locate database for the specified pattern

##locatedb="/var/locate.db"
locatedb="/var/lib/mlocate.db"

exec grep -i "$@" $locatedb
