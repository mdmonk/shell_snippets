#!/bin/bash
# disable Dashboard
defaults write com.apple.dashboard mcx-disabled -boolean YES
# restart Dock
killall Dock
