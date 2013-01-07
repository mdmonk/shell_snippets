#!/bin/bash

kill -9 `ps auxww | grep ${1} | grep -v grep | tr -s " " | cut -d" " -f2`
