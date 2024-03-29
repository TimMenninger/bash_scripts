#!/bin/bash -l

#
# A N D R O I D
#

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/willow2/mtk/SP_Flash_Tool_v5.1828_Linux/:/home/willow2/mtk/SP_Flash_Tool_v5.1828_Linux/lib

export PATH=/home/willow2/mtk/android/out/host/linux-x86/bin:$PATH



#
# G H S   T O O L S
#

export NH2017="/home/willow/nh2017"

SVN="/usr/bin/svn"

# GHS tools
export MULTI_DIR="/multi"
export GHSCOMP_DIR="/compiler"
export TOOLS_DIR="/tools"
export RTOS_DIR="/rtos/rtos"

export PATH=$MULTI_DIR:$GHSCOMP_DIR:$TOOLS_DIR/sitescripts:$PATH

# Phone project
export H1U_098_SN="UG9S8D7DJV4DR4VG"

# Required for multi
export GHS_LMHOST="#ghslm1,ghslm2,ghslm3"
export GHS_LMWHICH="ghs"

# Bash history tweaks
export HISTTIMEFORMAT=

# Special gbuild thanks to Ian
alias gb="color_gbuild"
alias gbuild="color_gbuild"
export GBUILD="$GHSCOMP_DIR/gbuild $1"
function color_gbuild() {
    date

    if [[ "$#" > 0 ]]; then
        set -- "-top" "$1/default.gpj" "${@:2}"
    fi

    command $GBUILD "$@" |& awk -f $NH2017/scripts/gbuild.awk

    return ${PIPESTATUS[0]}
}

# Print owners of all changed items
alias owners="/tools/sitescripts/gcomponent.py -m -o"
function owner() {
    /tools/sitescripts/gcomponent.py -o $@
}

# Set sym links for third party directory
function set_third_party_symlinks() {
    # relative to third_party
    SYMLINKS=(
        "opus/opus-1.2.1"
        "built/bin"
        "built/include"
        "built/lib"
        "built/share"
        "built_win64/include"
        "built_win64/lib"
        "libvpx/libvpx-1.8.1"
        "libyuv/libyuv"
        "SDL2/build"
        "protobuf-3.4.1"
    )

    if [ ! -d app_table ]; then
        echo "Not in nh2017 directory"
    fi

    for s in "${SYMLINKS[@]}"; do
        (cd third_party; mkdir -p $s; rm -rf $s; ln -sf /configs/nh2017_config/third_party/$s $s)
    done
}


#
# W I L L O W
#

alias willow="tmenninger@willow"



#
# N H 2 0 1 7
#

# Pytest lives here
export PATH=$HOME/.local/bin:$PATH

# NH2017 directories
alias nh2017="cd $NH2017"

# Pytest always-options
export PYTEST_ADDOPTS="-v --mtk_use_bmt --mtk_serial_number=SSNVTO6HMRQCS8KV --default_brightness=9999 --mtk_password=336699 --mtk_reset_via_testbench"

alias nh1='nh 1'
alias nh2='nh 2'
alias nh3='nh 3'
function nh() {
    if [ -z $1 ]; then
        cd $NH2017
    elif [ $1 -eq 0 ]; then
        cd $NH2017
    elif [ $1 -gt 0 ]; then
        cd $NH2017/../_nh2017_$1
    fi

    if [ ! -z $2 ]; then
        cd ${@:2}
    fi
}

# Clean
function aw_yis() {
    ORIG_DIR="$(pwd)"

    update_rtos &
    UPDATE_RTOS_PID="$!"

    if [[ "$(basename $(cd ../ ; pwd))" == *"nh2017"* ]]; then
        echo 1
        cd ..
    fi
    if [[ "$(basename $(cd ../../ ; pwd))" == *"nh2017"* ]]; then
        echo 2
        cd ../..
    fi
    if [[ "$(basename $(cd ../../../ ; pwd))" == *"nh2017"* ]]; then
        echo 3
        cd ../../..
    fi
    if [[ "$(basename $(cd ../../../../ ; pwd))" == *"nh2017"* ]]; then
        echo 4
        cd ../../../..
    fi

    set_third_party_symlinks

    GB=/compiler/gbuild
    wait $UPDATE_RTOS_PID

    PIDS=""
    if [[ "$(basename $(pwd))" == *"nh2017"* ]]; then
        # All linux can happen in parallel
        #
        # MTK Timemachine and noapps must happen in series, can be parallel with
        # linux and with release build
        #
        # Sequence here caters to likelihood of using it to get those done soon.
        # Not looking necessarily for fastest solution to get all done
        (cd mtk; ../scripts/remove_nonoutput.py -cfg=hicdebug; $GB -cfg=hicdebug) &
        MTK_PID="$!"

        (cd linux64; ../scripts/remove_nonoutput.py -cfg=hicdebug; $GB -cfg=hicdebug) &
        PIDS="$PIDS $!"
        (cd linux64; ../scripts/remove_nonoutput.py -cfg=nextdebug; $GB -cfg=nextdebug) &
        PIDS="$PIDS $!"
        (cd endpoints; ../scripts/remove_nonoutput.py -cfg=debug; $GB -cfg=debug) &
        PIDS="$PIDS $!"
        (cd endpoints; ../scripts/remove_nonoutput.py -cfg=release; $GB -cfg=release) &
        PIDS="$PIDS $!"

        wait $MTK_PID

        (cd mtk/bootmonitor; ../../scripts/remove_nonoutput.py; $GB) &
        PIDS="$PIDS $!"
        (cd mtk; ../scripts/remove_nonoutput.py -cfg=nextdebug; $GB -cfg=nextdebug) &
        PIDS="$PIDS $!"
        (cd mtk; ../scripts/remove_nonoutput.py -cfg=p1replay; $GB -cfg=nextdebug) &
        PIDS="$PIDS $!"
        (cd mtk; ../scripts/remove_nonoutput.py -cfg=p1release; $GB -cfg=nextdebug) &
        PIDS="$PIDS $!"

        wait $PIDS
        PIDS=""
    fi

    cd $ORIG_DIR
}

# Handle a report
function hr() {
    if [[ ! -d $DEBUG_NH2017 ]]; then
        if [[ ! -d /home/willow/debug-nh2017 ]]; then
            echo "Set DEBUG_NH2017!"
            return 1
        fi
        export DEBUG_NH2017=/home/willow/debug-nh2017
    fi

    CFG=""
    REBUILD=true
    REVERT=true

    POSITIONAL=()
    while [[ $# -gt 0 ]]; do
        arg=$1
        case $arg in
            -cfg=*)
                CFG="$(cut -d "=" -f 2 <<< $arg)"
                ;;
            -F)
                REVERT=false
                REBUILD=false
                ;;
            -B)
                REVERT=false
                REBUILD=true
                ;;
            *)
                POSITIONAL+=("$arg")
                ;;
        esac

        shift # Past argument
    done

    # Replace (maybe) positional, unparsed args
    set -- "${POSITIONAL[@]}"

    REPORT_PATH=$1
    if [[ ! -d $REPORT_PATH ]]; then
        echo "Needs argument containing path to replay.  Could not find \"$REPORT_PATH\""
        return 1
    fi

    if [[ "$REPORT_PATH" != /* ]]; then
        REPORT_PATH=$(pwd)/$REPORT_PATH
    fi

    # Gbuild clean with existing changes so we don't delete something that
    # causes us to keep a stale binary
    if $REVERT; then
        /compiler/gbuild -clean -top $DEBUG_NH2017/linux64/default.gpj -allcfg

        # Cleanup
        $SVN cleanup $DEBUG_NH2017

        # Revert existing changes
        $SVN revert -R $DEBUG_NH2017

        # Go to correct revision
        (cd $DEBUG_NH2017; $SVN up -r$(cat $REPORT_PATH/rev))

        # Apply necessary patch
        (cd $DEBUG_NH2017; $SVN patch $REPORT_PATH/patch)
    fi

    if $REBUILD; then
        # Build linux
        /compiler/gbuild -top $DEBUG_NH2017/linux64/default.gpj $CFG
    fi

    # Handle the report
    $DEBUG_NH2017/linux64/handle_report $REPORT_PATH
}

function make_phone_num() {
    BASE_NUM="2700000000"
    INPUT_NUM="$1"
    PHONE_NUM=${BASE_NUM:0:$((${#BASE_NUM}-${#INPUT_NUM}))}$1
    echo $PHONE_NUM
}

function clean_email() {
    PHONE_NUM="$(make_phone_num $1)"
    ${NH2017}/scripts/clean_mail.sh $PHONE_NUM
}

function run() {
    # Go to correct directory
    if [[ ! -d "linux64" ]]; then
        if [[ ! -d "../linux64" ]]; then
            return 1
        fi
        cd ..
    fi
    cd linux64

    # Parse arguments for options

    # Get correct phone number
    PHONE_NUM="$(make_phone_num $1)"

    # X Switches
    X_SWITCHES="
        -XCrashCalmly
        -XAllowAnyNumber
        -Xautologin
        -Xdisplay_borderless
        -Zlicense_manager_on
    "

    # Processes to show output for
    DEBUG=""
    SHOW_OUTPUT=""
    POSITIONAL=()
    while [[ $# -gt 0 ]]; do
        arg=$1
        case $arg in
            --db)
                DEBUG="-debug:"
                ;;
            --kb)
                SHOW_OUTPUT+="KEYBOARD,"
                ;;
            --gk)
                X_SWITCHES+=" -XGuikitNoisy "
                SHOW_OUTPUT+="GUIKIT,"
                ;;
            --sv)
                SHOW_OUTPUT+="SUPERVISOR,"
                ;;
            --ft)
                SHOW_OUTPUT+="FATHER_TIME,"
                ;;
            *)
                POSITIONAL+=("$arg")
                ;;
        esac

        shift # Past argument
    done

    # Replace (maybe) positional, unparsed args
    set -- "${POSITIONAL[@]}"

    # If the debug command is nonempty, add to it what we're debugging
    if [ "$DEBUG" != "" ]; then
        DEBUG+="${SHOW_OUTPUT}"
    fi

    # Build. If fail, stop here
    gb
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    # Run the phone
    ./run $PHONE_NUM -show-output:$SHOW_OUTPUT $X_SWITCHES $DEBUG ${@:2}
}

function svn_update_tools() {
    if [ ! -d /tools ]; then
        echo "Nothing at /tools"
        return 1
    fi

    REV=
    if [ ! -z $1 ]; then
        REV=$1
    fi

    (cd /tools; $SVN up $REV)
    (cd /tools; ./bin/scripts/cvlink update)
}

function build_libs() {
    (cd /tools/trg && ./build_lib -fixbuildlinks -arm64; ./build_lib -fixbuildlinks -intarm64 -blind; )#./build_lib -fixbuildlinks -linux86)
}

function update_libs() {
    svn_update_tools $@
    build_libs
}

function build_tools() {
    (cd /tools/linux64-comp && ../dobuild arm64_compiler_val.all linux86_compiler_val.all internal_tools_comp.all ghprobe_comp.all osa_linux_kernel.all)
    (cd /tools/linux64-ide && ../dobuild everything_ide.all)
    (cd /tools/trg && ./build_lib -fixbuildlinks -arm64; ./build_lib -fixbuildlinks -intarm64 -blind; )#./build_lib -fixbuildlinks -linux86)
}

function update_tools_only() {
    svn_update_tools $@
    build_tools
}

function update_tools() {
    update_tools_only $@
    build_libs
}

function update_rtos() {
    if [ ! -d /rtos ]; then
        echo "Nothing at /rtos"
        return 1
    fi

    (cd /rtos; $SVN up)
    (cd /rtos; ./setup.py)
    (cd /rtos/rtos/hoyos-sm835; ./setup.sh)
}



#
# T I C K E T S
#

if [ -d "/t/toolsvc/trunk/users/" ]; then
    # Whenever I check out a VM that has a tool checkout, start checking out my
    # users folder as soon as the vm starts up.
    cd /t/toolsvc/trunk/users
    $SVN up `whoami`
    $SVN up nh2017

    # Copy vimrc file
    cp /home/eng/users/tmenninger/.vimrc ~/.vimrc
fi

#
# M O U N T I N G   F S
#

function sshfs_ghs() {
    dir="/home/$1"
    machine="$2"
    if [[ -z $machine ]]; then
        machine="$1"
        # If folder ends in a 2, chop it off
        if [[ "$machine" =~ .*2 ]]; then
            machine="${machine::-1}"
        fi
    fi

    if [[ ! -d "$dir" ]]; then
        sudo mkdir -p "$dir"
        sudo chown tmenninger:root "$dir"
    else
        fusermount -u "$dir"
    fi
    sshfs "tmenninger@$machine:$dir" "$dir"
}

