#!/bin/bash

/bin/ps aux | awk '{ print $8 " " $2 }' | grep -w Z
