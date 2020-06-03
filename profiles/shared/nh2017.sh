#!/bin/bash -l

alias nh2017="cd $NH2017"

export PATH=$HOME/.local/bin:$PATH

export TEST_RCAR_ADDRESS='adunlap1'

# Other nh2017 checkouts
DEBUG_NH2017=$NH2017/../debug-nh2017

function get_flanders() {
    TEST_NUM=$1
    if [ -z TEST_NUM ]; then
        echo "Need test number as only argument"
        return
    fi
    (
    rm $TARBALL_NAME.tar.gz*
    cd /home/willow/replays
    TARBALL_NAME=commit_full_replay
    wget flanders.ghs.com/job/Phone/${TEST_NUM}/artifact/$TARBALL_NAME.tar.gz
    tar -zvxf $TARBALL_NAME.tar.gz
    rm $TARBALL_NAME.tar.gz
    )
}

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

# Handle a report
function hr() {
    if [[ ! -d $DEBUG_NH2017 ]]; then
        echo "Set DEBUG_NH2017!"
        return 1
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
        /home/aspen/my_compiler_working/linux64-comp/gbuild -clean -top $DEBUG_NH2017/linux64/default.gpj -allcfg

        # Cleanup
        svn cleanup $DEBUG_NH2017

        # Revert existing changes
        svn revert -R $DEBUG_NH2017

        # Go to correct revision
        svn up -r$(cat $REPORT_PATH/rev) $DEBUG_NH2017

        # Apply necessary patch
        svn patch $REPORT_PATH/patch $DEBUG_NH2017
    fi

    if $REBUILD; then
        # Build linux
        /home/aspen/my_compiler_working/linux64-comp/gbuild -top $DEBUG_NH2017/linux64/default.gpj $CFG
    fi

    # Handle the report
    $DEBUG_NH2017/linux64/handle_report $REPORT_PATH

}

# Pre commit for linux only
function pcl() {
    nh2017
    cd linux64
    gb
    cd ..
    pytest -m 'linux and pre_commit' tests -P2735700001
}

# Debug the test phone number
function dbpc() {
    nh2017
    cd linux64
    ./rdebug 2735700001 $1
}

# Pre commit
function pc() {
    nh2017
    ./pre_commit.sh
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
    nh2017
    if [[ ! -d "linux64" ]]; then
        return 1
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
        -Xdisplay_always_on_top
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
            --uc)
                SHOW_OUTPUT+="UBERCOMM,"
                ;;
            --cm)
                SHOW_OUTPUT+="CONTACT_MANAGER,"
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

function update_iot_partitions() {
    # go to IoT directory
    nh2017
    cd iot

    # build IoT and, if successful, flash images
    gb && cd bootloader; sudo ./flash_images.sh $IOT_PROBE
}

reset_pipe_buffers() {
    sudo sysctl fs.pipe-max-size=16777216
    sudo sysctl -w fs.pipe-user-pages-soft=0
}

# Runs the pytest tests
function nhtest() {
    OPTIONS=""
    DIRECTORY="tests"
    POSITIONAL=()
    while [[ $# -gt 0 ]]; do
        arg=$1
        case $arg in
            --keyboard)
                DIRECTORY="tests/keyboard"
                ;;
            --verbose)
                OPTIONS+=" -s"
                ;;
            --linux)
                OPTIONS+=" -m linux"
                ;;
            --display)
                OPTIONS+=" --display_linux"
                ;;
            *)
                POSITIONAL+=("$arg")
                ;;
        esac
        shift # past argument
    done

    (cd $NH2017;pytest $OPTIONS $DIRECTORY)
}
alias kb_test_linux='(nh2017;nhtest --linux --keyboard --verbose --display)'

# Building and updating nh2017
function build_then_run() {
    cd $NH2017
    cd linux64

    gbuild
    if [ $? -eq 0 ];
    then
        ./run $@
    fi
}

# Run N instances of phone
function runN() {
    nh2017
    gbuild
    if [ $? -eq 0 ];
    then
        counter=$1
        bound=$2
        if [ -z $bound ]
        then
            bound=0
        fi
        re='^[0-9]+$'
        if [[ $counter =~ $re ]]
        then
            while [ $counter -ge $bound ]
            do
                run $counter &
                ((counter--))
                sleep 1
            done
        fi
    fi
}

function grep_nh() {
    DIR="$NH2017/src $NH2017/libs $NH2017/app_table $NH2017/linux64/debug/gen/app_table/*.h $NH2017/linux64/debug/gen/app_table/*.c $NH2017/linux64/debug/work/*.h $NH2017/linux64/debug/work/*.c $NH2017/linux64/debug/work/*.genlayout $NH2017/linux64/default.gpj $NH2017/rcar_dynamic/hist/gen/app_table/*.h $NH2017/rcar_dynamic/hist/gen/app_table/*.c $NH2017/rcar_dynamic/hist/work/*.h $NH2017/rcar_dynamic/hist/work/*.c $NH2017/rcar_dynamic/hist/work/*.genlayout $NH2017/rcar_dynamic/default.gpj $NH2017/iot/tm/gen/app_table/*.h $NH2017/iot/tm/gen/app_table/*.c $NH2017/iot/tm/work/*.h $NH2017/iot/tm/work/*.c $NH2017/iot/tm/work/*.genlayout $NH2017/iot/default.gpj"
    if [[ ! -z "$2" ]]; then
        DIR=$2
    fi

    echo "grep -r -I -n $1 $DIR/"
    grep -r -I -n "$1" $DIR
}

# Replay
function rp() {
	if [ $# -eq 2 ]
	then
        (
        nh2017;
		cd linux64/images/$1;
        ./rdebug $2;
        )
	else
		echo "usage: rp [number] [process]"
	fi
}


