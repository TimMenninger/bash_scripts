#!/usr/bin/osascript

on backgroundcolor()
    # only allow dark-ish colors
    set maxValue to (2 ^ 14) - 1
    
    set redValue to random number from 0 to maxValue
    set greenValue to random number from 0 to maxValue
    set blueValue to random number from 0 to maxValue
    
    return {redValue, greenValue, blueValue}
end backgroundcolor

set newcolor to backgroundcolor()

tell application "Terminal"
    set the background color of the selected tab of window 1 to newcolor
end tell
