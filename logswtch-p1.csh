#!/bin/csh
#####################################################
# Script name: logswtch-p1.csh
# He who wrote it: Chuck
# description: It does a logswitch for each customer
#              on Provider-1.
#
#####################################################

# Then I set some variables for the date (6 digit format) and a variable
# for the logfile
####
# Do this...I forgot to code it in this ver. CWL
####

# Need to set some enviroment variables.
setenv FWDIR /opt/CPmds-41
setenv FWDIR_BASE /opt/CPmds-41

# Pipe some header information to the logfile so I can browse the next
# day to see how everything went.
####
# Do this...I forgot to code it in this ver. CWL
####

# Set the enviroment for Provider.
cd /opt/CPmds-41/bin
source setmdsenv

# Check to see if customers file exists. I keep this in the /log
# directory. Basically it's format is <ip address>:<client name>
if ( ! -r /logs/customers ) then
   echo Customers file is missing! Log processing will not continue! >> $log
   echo Check to make sure customers file is in /logs >> $log
   echo ""
else
   foreach customers ( `cat /logs/customers` )
      set ip = `echo $customers | cut -f1 -d: `
      set id = `echo $customers | cut -f2 -d: `
      echo Processing logfiles for "$id" "$ip" >> $log
      cd /opt/CPmds-41/customers/
      if ( ! -d /opt/CPmds-41/customers/"$ip" ) then
         echo Directory for "$id" "$ip" does not exist >> $log
         echo Moving on to next customer >> $log
         echo "" >> $log
      else
         mdsenv -v "$ip" #This set Providers enviroment to "this" cust.
         mcd log #Moves to customers log directory.
         fw logswitch bin
         if ( ! -e bin.log ) then
            echo Logswitch failed on customer "$id" "$ip" >> $log
            echo Moving on to next customer >> $log
            echo ""
         else
            mv bin* /logs/temp/.
            cd /logs/temp
            rm *.alog
            rm *.logptr
            rm *.alogptr
            fw logexport -i ./bin.log -o ./textlog -n
            if ( ! -e bin.logptr ) then
               echo bin.logptr does not exist >> $log
               echo Possible failure on log export >> $log
               echo Moving on to next customer >> $log
               echo "" >> $log
            else
               mv bin.log "$ip"-"$date".log
               mv bin.logptr "$ip"-"$date".logptr
               mv "$ip"* /logs/binlogs/.
               mv textlog "$id"-"$date".txt
               mv *.txt /logs/txtlogs/.
               cd /logs/txtlogs
               ls -al "$id"-"$date".txt >> $log
               cd /logs/binlogs
               ls -al "$ip"-"$date"* >> $log
               echo "" >> $log
            endif
         endif
      endif
   end
endif

# I need figure out how to clean up the mess this leaves behind  [;-)] 

## Now to ftp the files over you can make the ftp call via:
# ftp -nv < /etc/<filename> where <filename> holds the commands for the
# ftp session.

## Basically the ftp file is built like so:
# open <ip address of ftp server>
# user <username> <password>
# lcd /logs/txtlogs #or where ever you moved the logs to
# cd logs
# prompt
# mput *.txt
# bye
