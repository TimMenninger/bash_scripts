#!/bin/bash -l

# Main loop
function main() {
    build_tools
    build_nh2017
    build_bsps
    clean_things
    run_pre_commit
    return 0
}

# Environment stuff
source ~/.bashrc

# List of all directories to cd into for gbuild, absolute
export PROJ_BUILD_TARGETS=(
    # Linux build configurations
    "linux64/default.gpj -cfg=debug"
    "linux64/default.gpj -cfg=noapps"

    # MTK build configurations
    "mtk/default.gpj -cfg=timemachine"
    "mtk/default.gpj -cfg=release"

    # Android vmm
    "bsp/virtualization/default.gpj -cfg=checked -DANDROID"
)

# List of all directories to remove as part of cleaning
export PROJ_OUT_DIRS=(
    "linux64/noapps"
    "linux64/debug"
    "mtk/tm"
    "mtk/rel"
    "bsp/virtualization/chk"
)

export CHECKOUTS=(
    # Normal checkout
    $NH2017

    # Used for replays/debugging
    $DEBUG_NH2017

    # Other checkouts
    $NH2017/../_nh2017_{1..3}
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
    CHECKOUT=$1

    # Make sure third party stuff is up to date
    cd $CHECKOUT/third_party
    ./build_third_party.sh
}

# Do some general cleaning to try and keep disk usage down
function clean_things() {
    # For one reason or another, there's a bunch of garbage placed here
    rm -f /tftpboot/bak/*
}

# Update everything so we build on a clean slate
function svn_update() {
    CHECKOUT=$1

    # Create patch in case we botch things
    if [[ "" == "$(svn st)" ]]; then
        /usr/bin/svn cleanup $CHECKOUT
        /usr/bin/svn up $CHECKOUT
        if [[ $? -ne 0 ]]; then
            echo "Unable to update!"
            return 1
        fi
        for out_dir in "${PROJ_OUT_DIRS}"; do
            rm -rf $out_dir
        done
    fi

    # Update and only continue on success (might be merge conflicts or whatever)
    /usr/bin/svn cleanup $CHECKOUT
    if [[ $? -ne 0 ]]; then
        echo "Unable to update!"
        return 1
    fi

    # Remove unused images
    rm $CHECKOUT/linux64/images/1*

    # Success
    return 0
}

# Build GHS tools
function build_tools() {
    # Update
    svn up $MY_TOOLS_DIR

    # Build
    $MY_TOOLS_DIR/bin/scripts/cvlink update
    (cd $MY_TOOLS_DIR/linux-comp && ../dobuild everything_comp.all)
    (cd $MY_TOOLS_DIR/linux-ide && ../dobuild everything_ide.all)
    (cd $MY_TOOLS_DIR/trg && ./build_lib -fixbuildlinks -arm64 -86 -linux86 -68e -tricore -ppc -v800 -mips -arm -int86 -intcoldfire -intarm64 -intppc -intmips -intarm)
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

        # Update the repo
        svn_update $checkout; if [[ $? -ne 0 ]]; then continue; fi
    done

    # Build all
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
        if [[ $(svn st $checkout) ]]; then
            echo ""
            echo "Existing changes!"
            svn st
            continue
        fi

        # Build dependencies
        build_deps $checkout

        # Run the gbuild command in the correct directory
        for target_cfg in "${PROJ_BUILD_TARGETS[@]}"; do
            /home/aspen/my_compiler_working/linux64-comp/gbuild -cleanfirst -top $checkout/$target_cfg
            END_SECS=$(date +%s)
            END=$(date +%I:%M:%S%p)
        done

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
    if [ -d "${NH2017}/../bsp-nh2017" ]; then
        cd ${NH2017}/../bsp-nh2017
        /usr/bin/svn up
        svn cleanup
    fi

    if [ -d "/home/willow2/mtk/integrity" ]; then
        cd /home/willow2/mtk/integrity
        svn up
        svn cleanup
    fi

    if [ -d "/home/willow2/mtk" ]; then
        cd /home/willow2/mtk
        (cd android; git pull)
        (cd modem; git pull)
        /home/willow2/mtk/scripts/build.sh
    fi
}

function run_pre_commit() {
    cd ${NH2017}
    ./pre_commit.sh
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

