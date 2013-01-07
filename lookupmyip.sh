#!/usr/bin/env bash

nslookup `ifconfig en0 | grep netmask | cut -d" " -f2`
