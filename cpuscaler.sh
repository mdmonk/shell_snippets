#!/bin/bash
CURRENT=`cat /proc/cpuinfo | grep "^cpu MHz.*" | awk -F": " '{print $2}' | sed 's@\.@@g' | uniq`
if [ "${CURRENT}" == "1000000" ] ; then
SETA='TRUE';
SETB='FALSE';
SETC='FALSE';
fi
if [ "${CURRENT}" == "1333000" ] ; then
SETA='FALSE';
SETB='TRUE';
SETC='FALSE';
fi
if [ "${CURRENT}" == "1667000" ] ; then
SETA='FALSE';
SETB='FALSE';
SETC='TRUE';
fi
ans=$(zenity --list --text "Select CPU Speed" --radiolist --column "" --column "Speed" ${SETA} "1.0 GHz" ${SETB} "1.33 GHz" ${SETC} "1.67 GHz") ;
VALUE=1000000
if [ "${ans}" == "1.0 GHz" ] ; then
VALUE=100000;
fi
if [ "${ans}" == "1.33 GHz" ] ; then
VALUE=1333000;
fi
if [ "${ans}" == "1.67 GHz" ] ; then
VALUE=1667000 ;
fi
gksu "cpufreq-selector -f ${VALUE}"
