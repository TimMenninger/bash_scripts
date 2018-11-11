#!/bin/bash -l

# Paths
PATH=/home/compiler/tools_devl/working/linux64-comp:${PATH}
PATH=/home/multi/tools_devl/working/linux64-ide:${PATH}
PATH=${TOOLS_DIR}/sitescripts:${PATH}
PATH=${RTOS_DIR}/privutils/svn_commit:${PATH}
PATH=${RTOS_DIR}/privutils/gcomponent:${PATH}

# Stuff for using GHS tools
export GHS_LINUXSERV_USE_64_BIT=1

# gbuild binary
export GBUILD=${GHSCOMP_DIR}/gbuild $@

alias gb="color_gbuild"

## Bash history tweaks
export HISTTIMEFORMAT=
export EDITOR=vim

# Special gbuild thanks to Ian
function color_gbuild() {
    date

    command $GBUILD "$@" |& awk -f /home/eng/users/thompson/scripts/gbuild.awk

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
