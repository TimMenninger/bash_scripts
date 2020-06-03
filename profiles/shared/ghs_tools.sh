#!/bin/bash -l

# README
#
# This can take one argument, which is optional, which should be -DIN_VM if this
# is being run for a profile on a tickets vm
#

# Paths
export PATH=${GHSCOMP_DIR}:${PATH}
export PATH=${MULTI_DIR}:${PATH}
export PATH=${TOOLS_DIR}/sitescripts:${PATH}
export PATH=${RTOS_DIR}/privutils/svn_commit:${PATH}
export PATH=${RTOS_DIR}/privutils/gcomponent:${PATH}

# Stuff for using GHS tools
export GHS_LINUXSERV_USE_64_BIT=1

# gbuild binary
export GBUILD="${GHSCOMP_DIR}/gbuild $1"

export PATH=/home/willow2/mtk/android/out/host/linux-x86/bin:$PATH

alias gb="color_gbuild"
alias pytest="/home/eng/users/tmenninger/.local/bin/pytest"

## Bash history tweaks
export HISTTIMEFORMAT=

# Special gbuild thanks to Ian
function color_gbuild() {
    date

    command $GBUILD "$@" |& awk -f ${NH2017}/scripts/gbuild.awk

    return ${PIPESTATUS[0]}
}

# Searching particular directories
function grep_INTEGRITY() {
    if ! ll $RTOS_DIR; then
        echo "RTOS_DIR not set"
        return 1
    fi

    echo 'grep -r '"$1" $RTOS_DIR'/INTEGRITY-include | grep -v Binary'
    grep -r "$1" $RTOS_DIR/INTEGRITY-include --exclude-dir=.svn | grep -v Binary
    echo ''
    echo 'grep -r '"$1" $RTOS_DIR'/INTEGRITY-libs | grep -v Binary'
    grep -r "$1" $RTOS_DIR/INTEGRITY-libs --exclude-dir=.svn | grep -v Binary
}
