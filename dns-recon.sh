#!/bin/bash
#Copyright (c) 2011 Tom Webb
#tcw3bb@gmail.com
#Version 1.0
#irhowto.wordpress.com
#Usage dns_recon.sh 1.2.3
#Robtext does this by class c networks.
# It will go through the class be of the network

USERAGENT="Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)"

TMP=$(mktemp -d /tmp/dnsfile.XXXXXXXX)
cd $TMP

#Chech to see if w3m is installed
if ! builtin type -p w3m &>/dev/null; then
echo  "you need to install w3m"
echo "OSX type: sudo port install w3m"
echo  "Ubuntu type: sudo apt-get install w3m"
fi



if [ -z "$1" ]; then
  echo -e "\nUsage: `basename $0` 1.2.3 \n\nYou specify up to the first three octects (Class C)\nOutput to standard out in csv"
  exit 1
fi

IP=$1

recon ()
{

bar="=================================================="
barlength=${#bar}

case $oct_count in

1) #Class A SCAN
    count=0
     while (( $count < 65536 )); do
        for a in $(seq 0 1 255);
         do
                n=$(($count*barlength / 65536))
                 printf "\r[%-${barlength}s]" "${bar:0:n}" >&2

                 for b in $(seq 0 1 255);
                   do
                        get --quiet -U "$USERAGENT" http://www.robtex.com/cnet/$IP.$a.$b.html && sleep 1
                        ((count ++))
                    done
         done
       done
        ;;

2) #Class B SCAN
                count=0
                while (( $count < 255)); do
                n=$(($count*barlength / 255))
                printf "\r[%-${barlength}s]" "${bar:0:n}" >&2
                        wget --quiet -U "$USERAGENT" http://www.robtex.com/cnet/$IP.$count.html && sleep 1
                ((count ++ ))
                done


        ;;
3) #Class C Scan
        wget --quiet -U "$USERAGENT" http://www.robtex.com/cnet/$IP.html
        ;;

esac

}

convert_html ()
{

for file in `ls -m1`
do
        w3m -dump $file >$file.txt
        grep -E '(^|[[:space:]])[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*([[:space:]]|$)' $file.txt | sed 's/^ *//' |grep '^[a-zA-Z]'|awk '{print $1","$2","$3}'
done

}


clean ()
{
rm  -rf $TMP
}

#error check for ending period
if [[ $IP  =~ \.$ ]];
        then echo "Do not end address with a dot"
        exit 1
fi

#Determine the octect count
oct_count=`echo $IP |awk -F '.' '{ print NF}'` #Count the number of . in input

if [ $oct_count -gt 3 ];
        then
                echo "Please enter the first 3 or less octects"
                exit 1
        else
                recon
fi
convert_html
clean