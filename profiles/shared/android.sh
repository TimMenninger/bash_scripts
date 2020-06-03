#!/bin/bash -l

# Starts gserial for android
alias andser="sudo $(which gserial) -baud 115200 /dev/ttyUSB0"

alias flash_tool="bash /home/willow2/mtk/SP_Flash_Tool_v5.1828_Linux/flash_tool.sh"
alias mtk_flash="flash_tool -c format-download -s /android/build_result/MT6771_Android_scatter.txt"
alias mtk_flash_gui="/home/willow2/mtk/SP_Flash_Tool_v5.1828_Linux/flash_tool"

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/willow2/mtk/SP_Flash_Tool_v5.1828_Linux/:/home/willow2/mtk/SP_Flash_Tool_v5.1828_Linux/lib

function install_bridge_app() {
    #sudo /home/aspen/android/sdk/platform-tools/adb uninstall ghs.screen_driver
   sudo /home/aspen/android/sdk/platform-tools/adb install -t -r /home/aspen2/android_app/ghs_app.apk
}
