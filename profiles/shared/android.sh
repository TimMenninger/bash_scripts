#!/bin/bash -l

# Starts gserial for android
alias andser="sudo $(which gserial) -baud 115200 /dev/ttyUSB0"

function install_bridge_app() {
    #sudo /home/aspen/android/sdk/platform-tools/adb uninstall ghs.screen_driver
   sudo /home/aspen/android/sdk/platform-tools/adb install -t -r /home/aspen2/android_app/ghs_app.apk
}
