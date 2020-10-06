#!/bin/bash -l

# Main loop
function main() {
    build_nh2017
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

# Sets environment variables used here
function set_env() {

    # Need output directory if it isn't there
    if [ ! -d "~/out" ]; then
        mkdir ~/out
    fi

    # Success
    return 0
}

# Update everything so we build on a clean slate
function svn_update() {
    CHECKOUT=$1

    # Create patch in case we botch things
    /usr/bin/svn cleanup $CHECKOUT
    if [[ "" == "$(/usr/bin/svn st $CHECKOUT)" ]]; then
        /usr/bin/svn up $CHECKOUT
    else
        echo "Existing changes"
        echo "$(/usr/bin/svn st)"
        return 1
    fi

    # Update and only continue on success (might be merge conflicts or whatever)
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

        # Time the command
        START_SECS=$(date +%s)
        START=$(date +%I:%M:%S%p)

        # Declare what is being build
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "$checkout"
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

        # Build dependencies
        build_deps $checkout

        # Run the gbuild command in the correct directory
        for target_cfg in "${PROJ_BUILD_TARGETS[@]}"; do
            /home/aspen/my_compiler_working/linux64-comp/gbuild -top $checkout/$target_cfg -nice
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

