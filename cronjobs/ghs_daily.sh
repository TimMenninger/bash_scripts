#!/bin/bash -l

# Main loop
function main() {
    build_nh2017
    build_bsps
    clean_things
    run_pre_commit
    return 0
}

# Environment stuff
source ~/.bashrc

# List of all directories to cd into for gbuild, absolute
export PROJ_BUILD_CFGS=(
    # Linux build configurations
    "linux64/default.gpj"

    # Rcar dynamic build configurations
    "rcar_dynamic/default.gpj"

    # IoT build configurations
    "iot/default.gpj"
)

export CHECKOUTS=(
    # Normal checkout
    $NH2017

    # Used for replays/debugging
    $DEBUG_NH2017

    # Always has clean checkout
    $NH2017/../clean-nh2017

    # Other checkouts
    $NH2017/../_nh2017_{1..4}
)

export MONO_DIRS=(
    "${NH2017}/rcar_monolith"
)

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
    ./build_all.sh
}

# Do some general cleaning to try and keep disk usage down
function clean_things() {
    # SVN clean can save space
    cd $NH2017
    svn cleanup

    # SVN clean can save space
    if [ -d $NH2017/../clean-nh2017 ]; then
        cd $NH2017/../clean-nh2017
        svn cleanup
    fi

    # For one reason or another, there's a bunch of garbage placed here
    rm /tftpboot/bak/*
}

# Update everything so we build on a clean slate
function svn_update() {
    CHECKOUT=$1

    # Create patch in case we botch things
    if [[ "" == "$(svn st)" ]]; then
        /usr/bin/svn up $CHECKOUT
    fi

    # Update and only continue on success (might be merge conflicts or whatever)
    /usr/bin/svn cleanup $CHECKOUT
    if [[ $? -ne 0 ]]; then
        echo "Unable to update!"
        return 1
    fi

    # Success
    return 0
}

# Build nh2017 stuff
function build_nh2017() {
    # Remove extraneous images
    if [ -d linux64/images ]; then
        cd linux64/images
        find . ! -name '27000' -exec rm -rf {} +
    fi

    # Build all
    for checkout in "${CHECKOUTS[@]}"; do
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

        # Update the repo
        svn_update $checkout; if [[ $? -ne 0 ]]; then continue; fi

        # Run the gbuild command in the correct directory
        /home/aspen/my_compiler_working/linux64-comp/gbuild -cleanfirst -top $checkout -allcfg
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

    # Build monoliths
    for i in "${MONO_DIRS[@]}"; do
        # Time the command
        START_SECS=$(date +%s)
        START=$(date +%I:%M:%S%p)

        # Declare what is being build
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "$i"
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

        # Run the gbuild command in the correct directory
        cd $i
        ./update_mono.sh
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

    # Update the DTB
    cd "${NH2017}/rcar_dynamic/devtree"
    ./update_dtb.sh

    # Build BSP stuff
    if [ -d "${NH2017}/../nh2017_bsps" ]; then
        cd $NH2017/../nh2017_bsps
        /usr/bin/svn up
        /usr/bin/svn cleanup
    fi
}

function build_bsps() {
    if [ -d "${NH2017}/../nh2017_bsps" ]; then
        cd ${NH2017}/../nh2017_bsps
        /usr/bin/svn up
        svn cleanup
    fi
}

function run_pre_commit() {
    cd ${NH2017}
    ./pre_commit --noiot
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

