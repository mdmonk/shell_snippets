#!/bin/bash

dig @138.195.138.195 goret.org. axfr | grep '^c..\..*A' | sort | cut -b5-36 | perl -e 'while(<STDIN>){print pack("H32",$_)}' | gzip -dc
