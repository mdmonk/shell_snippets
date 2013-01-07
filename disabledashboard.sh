#!/bin/bash

##To turn Dashboard off:
defaults write com.apple.dashboard mcx-disabled -boolean YES 
##To turn Dashboard on:
# defaults write com.apple.dashboard mcx-disabled -boolean NO 
##You have to restart the Dock after making either change for it to take effect:
killall Dock 
