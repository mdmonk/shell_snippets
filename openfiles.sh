#!/bin/bash

#sudo lsof | grep ' root ' | awk '{print $NF}' | sort | uniq | wc -l
sudo lsof | grep " $1 " | awk '{print $NF}' | sort | uniq | wc -l
