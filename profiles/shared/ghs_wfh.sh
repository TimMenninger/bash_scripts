#!/bin/bash -l

export GHS_LMHOST="#ghslm1,ghslm2,ghslm3"

# Given by ghs
export TOOLS_DIR="/home/multi/tools_devl/working"

# GHS tools
export MULTI_DIR="/home/multi/tools_devl/working/linux64-ide"
export GHSCOMP_DIR="/home/compiler/my_compiler_working/linux64-comp"

# Required for multi
export GHS_ALLOW_LOCAL_LICENSE=1
export LICENSE_FILE_DIR=/home/willow/license/

# Point pytest to workstation
alias pytest="/home/eng/users/tmenninger/.local/bin/pytest"

# Connect to vpn
function vpn() {
    sudo vpnc-disconnect
    sudo vpnc-connect ghs
}

