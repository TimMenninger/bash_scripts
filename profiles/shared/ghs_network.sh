#!/bin/bash -l

# Given by ghs
export TOOLS_DIR="/home/multi/tools_devl/working"
export PATH=${TOOLS_DIR}/sitescripts:${PATH}

# GHS tools
export MULTI_DIR="/home/multi/tools_devl/working/linux64-ide"
export GHSCOMP_DIR="/home/compiler/tools_devl/working/linux64-comp"
export RTOS_DIR="/home/integrity/autobuild/checkouts/main/tools-main/working/rtos"

# Required for multi
export GHS_LMHOST="#ghslm1,ghslm2,ghslm3"
export GHS_LMWHICH="ghs"

# Use common version of adb
alias adb='/home/aspen/android/sdk/platform-tools/adb'
