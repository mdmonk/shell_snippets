#!/bin/sh

rrdtool graph cpu.png \
    --title 'rosalyn CPU usage' \
    -s 'now - 1 week' \
    -e 'now' \
    DEF:user=cpu.rrd:user:AVERAGE \
    DEF:nice=cpu.rrd:nice:AVERAGE \
    DEF:system=cpu.rrd:system:AVERAGE \
    DEF:iowait=cpu.rrd:iowait:AVERAGE \
    AREA:user#0000ff:user \
    STACK:nice#00ff00:nice \
    STACK:system#ff0000:system \
    STACK:iowait#ffff00:iowait
