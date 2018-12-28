#!/bin/bash -l

alias nh2017="cd $NH2017"

export PATH=$HOME/.local/bin:$PATH

export TEST_RCAR_ADDRESS='adunlap1'

function get_flanders() {
    TEST_NUM=$1
    if [ -z TEST_NUM ]; then
        echo "Need test number as only argument"
        return
    fi
    wget flanders.ghs.com/job/Phone/${TEST_NUM}/artifact/last_test_replay.tar.gz
    tar -zvxf last_test_replay.tar.gz
    mv last_test_replay flanders_build_${TEST_NUM}
    rm last_test_replay.tar.gz
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

function run() {
    # Go to correct directory
    nh2017
    if [[ ! -d "linux64" ]]; then
        return 1
    fi
    cd linux64

    # Parse arguments for options

    # Get correct phone number
    BASE_NUM="2700000000"
    INPUT_NUM="$1"
    PHONE_NUM=${BASE_NUM:0:$((${#BASE_NUM}-${#INPUT_NUM}))}$1

    # X Switches
    X_SWITCHES="
        -Zuse_ipc_timeouts
        -XCrashCalmly
        -XAllowAnyNumber
    "

    # Processes to show output for
    SHOW_OUTPUT="UBERCOMM,SUPERVISOR,CONTACT_MANAGER"
    POSITIONAL=()
    while [[ $# -gt 0 ]]; do
        arg=$1
        case $arg in
            --guikit)
                X_SWITCHES+=" -XGuikitNoisy "
                SHOW_OUTPUT+=",GUIKIT"
                ;;
            *)
                POSITIONAL+=("$arg")
                ;;
        esac

        shift # Past argument
    done

    # Replace (maybe) positional, unparsed args
    set -- "${POSITIONAL[@]}"

    # Build. If fail, stop here
    gb
    if [[ $? -ne 0 ]]; then
        return 1
    fi

    # Run the phone
    ./run $PHONE_NUM -show-output:$SHOW_OUTPUT $X_SWITCHES ${@:2}
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
    DIR=$NH2017
    if [[ ! -z "$2" ]]; then
        DIR=$2
    fi

    echo 'grep -r "$1" $DIR/ --exclude=src/fs_loader/*generated* --exclude-dir=rcar* --exclude-dir=atf --exclude-dir=hikey* --exclude-dir=browser --exclude-dir=simarm64 --exclude-dir=linux64 --exclude-dir=.svn --exclude-dir=objs --exclude-dir=third_party | grep -v Binary | grep -v "\.generated*"'
    grep -r "$1" $DIR/ --exclude=src/fs_loader/ --exclude-dir=rcar* --exclude-dir=atf --exclude-dir=hikey* --exclude-dir=browser --exclude-dir=simarm64 --exclude-dir=linux64 --exclude-dir=.svn --exclude-dir=objs --exclude-dir=third_party | grep -v Binary | grep -v "\.generated*"
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


