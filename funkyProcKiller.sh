#!/bin/sh
#################################################################
# Script Name:   funkyProcKiller.sh
# Author:        MdMonk, DFT, 2000
# Desc:          This script, will see if a process is running,
#                check to see if it's parent pid is '1', then
#                kill it.
# Obvious Stuff: You need to be the owner of the proc or r00t. 
#################################################################

procName="xvsb.db"

# put a couple of blank lines between the output.
echo
echo

parent=`ps -efa | grep $procName | grep -v grep | tr -s " " | cut -f3 -d" "`

if [ "$parent" = "1" ]; then
   dieProc=`ps -efa | grep $procName | grep -v grep | tr -s " " | cut -f2 -d" "`
   `kill -9 $dieProc`
   echo "You killed $procName! Thou shalt burn in the lower depths of hell for this."
else
   echo "Process $procName not running. (at least not with the parent pid of 1)"
   echo "Please drive through."
fi

# put a couple of blank lines between the output, again.
echo
echo
echo "This script brought to you by the letters: 'D', 'F', 'T', and"
echo "the number 5."
echo
