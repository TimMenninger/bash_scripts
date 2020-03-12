#!/bin/bash -l

# Given by ghs
export TOOLS_DIR="/home/multi/tools_devl/working"
export PATH=${TOOLS_DIR}/sitescripts:${PATH}

# GHS tools
export MULTI_DIR="/home/multi/tools_devl/working/linux64-ide"
export GHSCOMP_DIR="/home/aspen/my_compiler_working/linux64-comp"
export RTOS_DIR="/home/integrity/autobuild/checkouts/main/tools-main/working/rtos"

# Required for multi
export GHS_LMHOST="#ghslm1,ghslm2,ghslm3"
export GHS_LMWHICH="ghs"

# Probe hostname
export IOT_PROBE=ghprobe37563

# Point pytest to workstation
alias pytest="/home/eng/users/tmenninger/.local/bin/pytest"

# Grab changes and run pre commit
function vm_pre_commit() {
    # Create a VM
    resp=$(curl -X POST -H "Content-Type: application/json" -d "{ \"type\" : 21, \"token\" : \"tmenninger\" }" http://tickets.ghs.com/api/ticket/28000/vms)

    # Grab address from it
    addr_with_colon=$(echo $resp | grep -o "vnc_addr.*" | grep "192\.168\S*:")
    addr=${addr_with_colon::-1}
}
