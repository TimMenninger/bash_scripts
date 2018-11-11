#!/bin/bash -l

# Main loop
function main() {
    svn_update; if [[ $? -ne 0 ]]; then return $?; fi
    build_deps
    build_nh2017
    return 0
}

# Environment stuff
source ~/.bashrc

# List of all directories to cd into for gbuild, absolute
export PROJ_DIRS=(
    "${NH2017}/linux64"
    "${NH2017}/rcar_dynamic"
)

export MONO_DIRS=(
    "${NH2017}/rcar_monolith"
    "${NH2017}/rcar_unified_monolith"
)

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
        # Time the command
        START=$(date +%s.%N)

        # Declare what is being build
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "$i"
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

        # Run the gbuild command in the correct directory
        cd $i
        /home/compiler/tools_devl/working/linux64-comp/gbuild -cleanfirst
        END=$(date +%s.%N)
        DIFF=$(echo "$END - $START" | bc)

        # Print out the time
        echo ""
        echo "Start:    " $START
        echo "End:      " $END
        echo "Duration: " $DIFF
        echo ""
    done

    # Build monoliths
    for i in "${MONO_DIRS[@]}"; do
        # Time the command
        START=$(date +%s.%N)

        # Declare what is being build
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
        echo "$i"
        echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

        # Run the gbuild command in the correct directory
        cd $i
        ./update_mono.sh
        END=$(date +%s.%N)
        DIFF=$(echo "$END - $START" | bc)

        # Print out the time
        echo ""
        echo "Start:    " $START
        echo "End:      " $END
        echo "Duration: " $DIFF
        echo ""
    done
}

set -x
main $@
RET=$?
set +x
exit $RET

