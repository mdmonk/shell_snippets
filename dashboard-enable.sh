#!/bin/bash
# enable Dashboard
defaults write com.apple.dashboard mcx-disabled -boolean NO
# restart Dock
killall Dock
