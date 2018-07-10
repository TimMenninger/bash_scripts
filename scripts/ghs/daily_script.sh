#!/bin/bash

# Main loop
function main() {
    set_env;    if [[ $? -ne 0 ]]; then; return $?; fi
    svn_update; if [[ $? -ne 0 ]]; then; return $?; fi
    build_deps
    build_nh2017
    return 0
}

# Sets environment variables used here
function set_env() {
    # Go into the nh2017 directory
    if [ -d "/tools/users/nh2017" ]; then
        export NH2017=/tools/users/nh2017
    elif [ -d "/home/willow/nh2017" ]; then
        export NH2017=/home/willow/nh2017
    else
        echo "No nh2017 directory"
        return 1
    fi

    # List of all directories to cd into for gbuild, absolute
    declare -a PROJ_DIRS=(
        "${NH2017}/linux64"
        "${NH2017}/rcar_dynamic"
        "${NH2017}/rcar_dynamic_no_android"
        "${NH2017}/rcar_simple"
        "${NH2017}/simarm64"
    )

    # Success
    return 0
}

# Some things that are built require third party dependencies
function build_deps() {
    # Make sure third party stuff is up to date
    cd $NH2017/third_party
    ./build_all.sh
}

# Update everything so we build on a clean slate
function svn_update() {
    # Create patch in case we botch things
    cd $NH2017
    /usr/bin/svn diff > ../crontab_diff.patch

    # Update and only continue on success (might be merge conflicts or whatever)
    /usr/bin/svn up
    if [[ $? -ne 0 ]]; then
        echo "Unable to update!"
        return 1
    fi

    # Success
    return 0
}

# Build nh2017 stuff
function build_nh2017() {
    # Build all
    for i in "${PROJ_DIRS[@]}"; do
        cd $i
        rm -rf bin/* objs/* hist/*
        /home/compiler/tools_devl/working/linux64-comp/gbuild -cleanfirst
    done
}

set -x
main $@
RET=$?
set +x
exit $RET

