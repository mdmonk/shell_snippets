#!/bin/bash

for a in $(find /etc /var -name '*.rpm?*'); do b=${a%.rpm?*}; diff -u $a $b; done
