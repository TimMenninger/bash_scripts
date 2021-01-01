#!/bin/bash -l

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null ; pwd -P )"

SVN="/usr/bin/svn"

# Main loop
function main() {
    update_tools
    update_rtos

    build_deps

    PIDS=""
    update_users &
    PIDS="$PIDS $!"
    build_nh2017 &
    PIDS="$PIDS $!"
    build_bsps &
    PIDS="$PIDS $!"
    clean_things &
    PIDS="$PIDS $!"

    wait $PIDS

    return 0
}

export CONFIGS_DIR="/configs/nh2017_config"
export WILLOW_DIR="/home/willow"

# Environment stuff
source ~/.bashrc

# List of all directories to remove as part of cleaning
export PROJ_OUT_DIRS=(
    "linux64/noapps"
    "linux64/debug"
    "mtk/tm"
    "mtk/demo"
    "mtk/noapps"
    "bsp/virtualization/chk"
)

export CHECKOUTS=(
    # Normal checkout
    $WILLOW_DIR/nh2017

    # Used for replays/debugging
    $WILLOW_DIR/debug-nh2017

    # Other checkouts
    $WILLOW_DIR/_nh2017_{1..3}
)

# Tools directory
export MY_TOOLS_DIR="/home/willow/tools"

# Takes a number of seconds and outputs Xh Ym Zs
function format_duration() {
    DURATION=$1

    HRS=$(($DURATION / 60 / 60))
    DURATION=$(($DURATION-$(($HRS * 60 * 60))))

    MINS=$(($DURATION / 60))
    DURATION=$((DURATION-$(($MINS * 60))))

    SECS=$DURATION

    FMT=""
    if [[ $HRS > "0" ]]
    then
        FMT="${FMT}${HRS}h "
    fi

    if [[ $MINS > "1" ]]
    then
        FMT="${FMT}${MINS}m "
    elif [[ $HRS > "0" ]]
    then
        FMT="${FMT}00m "
    fi

    FMT="${FMT}${SECS}s"

    echo $FMT
}

# Sets environment variables used here
function set_env() {

    # Need output directory if it isn't there
    if [ ! -d "~/out" ]; then
        mkdir ~/out
    fi

    # Success
    return 0
}

# Some things that are built require third party dependencies
function build_deps() {
    # Make sure third party stuff is up to date
    cd $CONFIGS_DIR/third_party
    $SVN up
    ./build_third_party.sh
}

# Do some general cleaning to try and keep disk usage down
function clean_things() {
    # For one reason or another, there's a bunch of garbage placed here
    rm -f /tftpboot/bak/*

    # Remove unused images
    mv $CONFIGS_DIR/images/2700000123 /tmp/
    rm -rf $CONFIGS_DIR/images/*
    mv /tmp/2700000123 $CONFIGS_DIR/images/
}

# Update user checkouts
function update_users() {
    export USERS=(
        "tmenninger"
        "nikola"
        "ndf_scripts"
    )

    for u in "${USERS[@]}"; do
        (cd /users/$u; $SVN cleanup; $SVN up)
    done
}

# Build nh2017 stuff
function build_nh2017() {
    # Remove extraneous images
    if [ -d linux64/images ]; then
        cd linux64/images
        find . -maxdepth 1 ! -name '270000012*' -exec rm -rf {} +
        find . -name '*.partial' -delete
        find . -name 'TESTER' -exec rm -rf {} +
    fi

    # Update all
    for checkout in "${CHECKOUTS[@]}"; do
        if [ ! -d $checkout ]; then
            continue
        fi

        # Time the command
        START_SECS=$(date +%s)
        START=$(date +%I:%M:%S%p)

        # Declare what is being build
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "$checkout"
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

        # If there are outstanding changes, don't touch the directory
        if [[ $($SVN st $checkout) ]]; then
            echo ""
            echo "Existing changes!"
            $SVN st
            continue
        fi

        # Update the repo
        $SVN cleanup $checkout
        $SVN update $checkout

        # Run the gbuild command in the correct directory
        (cd $checkout; aw_yis)

        # Done timing
        END_SECS=$(date +%s)
        END=$(date +%I:%M:%S%p)

        DIFF=$(( $END_SECS - $START_SECS ))

        # Print out the time
        echo ""
        echo "Start:    " $START
        echo "End:      " $END
        echo "Duration: " $(format_duration $DIFF)
        echo ""
    done
}

function build_bsps() {
    if [ -d "$WILLOW_DIR/bsp-nh2017" ]; then
        cd $WILLOW_DIR/bsp-nh2017
        $SVN up
        $SVN cleanup
    fi
}

# Time the entire thing
SCRIPT_START_SECS=$(date +%s)
SCRIPT_START=$(date +%I:%M:%S%p)

set -x
main $@
RET=$?
set +x

# Get end time to display timing stats
SCRIPT_END_SECS=$(date +%s)
SCRIPT_END=$(date +%I:%M:%S%p)

SCRIPT_DIFF=$(( $SCRIPT_END_SECS - $SCRIPT_START_SECS ))

# Display timing stats
echo ""
echo "Start:    " $SCRIPT_START
echo "End:      " $SCRIPT_END
echo "Duration: " $(format_duration $SCRIPT_DIFF)
echo ""

exit $RET

