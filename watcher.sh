#!/bin/bash

## This shell-script is intended to be seen and modified.
## It should work on Mac OS 10.2 and up, with the BSD subsystem installed.
## If you didn't install BSD, this script will probably fail.
## It may work in other configurations, but I haven't tried it.
## - - - - -
## Originally written by Gregory Guerin.
## PROVIDED AS-IS AND WITHOUT WARRANTY OF ANY KIND.
## RELEASED INTO THE PUBLIC DOMAIN: 31 OCT 2004.  BOO!


# Watcher -- watches for changes made by Opener installation.

# This script watches for changes in certain places: the StartupItems dirs.
# It performs a check every 15 seconds, by default.
# Very little CPU is needed to perform a check, so more frequent checks are possible. 
# You can change the interval here:
betweenChecks=15

# When a change is seen, a message is spoken using Mac OS X's speech synthesis.
# Also, a timestamped message is written to stdout.
# You can change the action by editing the function eachFailure below.


# YOU MUST BE FREE OF INFECTION BEFORE RUNNING THIS SCRIPT.
# When this script detects a change, you should immediately determine the cause.
# It will continue to complain about the change until you quit it.
# When you rerun it, it will take the then-current state of the directories
# as the new baseline, and only complain about subsequent changes.
# So if you run it when you're already infected, it WILL NOT see a change.

# There are many ways that Opener can defeat this little script.
# I won't list them.  They involve hiding information from the
# commands used to check integrity (md5), or subverting commands
# used to detect changes (ls), or even subverting bash itself.


## FUNCTIONS

# This function is invoked each time a change is detected
# on each iteration of the main watching loop.
# You can edit this function to do anything you want.
# By default, it emits a message to stdout
# and also speaks the name of what changed.
# You can change it to send an email, write to a served web-page,
# post to a URL, dial a pager number, or any other commands you want.
# To run an AppleScript, see the man-page of the 'osascript' command.
function eachFailure ()
{
  # Echo a time-stamped complaint to system console log.
  echo `date` "-- Change in" "$@"

  # Speak complaint using default voice.
  osascript -e "say \"Attention, $1 was changed\""
}


# This function produces output characterizing the state of a file or dir.
# When the state changes, the output should change.
# The output is used to calculate the MD5 hash for each dir being watched.
# It can also be used as a debugging aid.
function characterize ()
{ ls -lTond "$@"; ls -lTon "$@"; }


## MAIN CODE

# The 'watchItems' array holds dir-names to watch for changes.
# You can edit it here.
# It's declared read-only to avoid accidental changes.
# Its length and values determine what the rest of the script checks.
declare -ra watchItems=('/System/Library/Startupitems' '/Library/StartupItems')



# Determine length of watchItems, as a read-only integer.
declare -ri watchCount=${#watchItems[*]}

# Calculate reference MD5 hash of each directory in watchItems.
# The directory must exist and be readable to the current user.
for (( i=0; i< watchCount; ++i ))
do
  item="${watchItems[i]}"

  # Only calculate a hash if item is an existing directory.
  hash=0
  test -d "$item" && hash=`characterize "$item" | md5`

  watchHashes[i]="$hash"

  # echo "#####" ; characterize "$item"
  echo "$i : $hash : $item"
done

declare -r watchHashes


# MAIN LOOP -- runs until quit, interrupted, or logout.

while true
do
  # Calculate MD5 hash of each directory in watchItems, and
  # compare to its reference value.
  for (( i=0; i< watchCount; ++i ))
  do
    item="${watchItems[i]}"
    ref="${watchHashes[i]}"

    # Only calculate a hash if item is an existing directory.
    hash=0
    test -d "$item" && hash=`characterize "$item" | md5`

    # If hash differs from reference, run eachFailure.
    test "$hash" != "$ref" && eachFailure "$item"
  done

  # Param is how long between checks, measured in seconds.
  sleep "$betweenChecks"
done