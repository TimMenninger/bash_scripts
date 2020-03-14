#!/bin/bash -l

# IP for ssh'ing into laptop
export LAPTOP="tmenninger@192.168.98.34"
export DESKTOP='tmenninger@192.168.1.101'
export WORKSTATION='tmenninger@willow.ghs.com'

# Editor of choice
export EDITOR=vim

# UCSB Pulse VPN
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/pulse

# Vivado licenses when on UCSB VPN
export LM_LICENSE_FILE="2100@license.ece.ucsb.edu"

alias ip='ifconfig | grep ".*Bcast" | grep -o "addr:[0-9\.]*" | grep -o "[0-9\.]*"'
alias printsource="enscript -C -DDuplex:true -DCollate:true -G2rE -f Courier@6 --margins=20:20:15:15"
alias dv="diffview"
alias vim='stty -ixon;vim'
alias chrome='(google-chrome-stable &> /dev/null) &'
alias vimrc='vim ~/.vimrc'
alias sourcebash='source $BASH_PROFILE'
alias bashprofile='vim $BASH_PROFILE;sourcebash'
alias bashrc='vim $BASH_PROFILE;sourcebash'
alias aws='ssh -i ~/zonedin.pem ubuntu@13.58.184.126'
alias ghs='ssh $WORKSTATION'
alias home='cd ~'
alias base='cd /'
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'
alias ticketsrc='vim ~/scripts/profiles/tickets.sh'
alias ll='ls -lah'
alias cll='clear; ll'
alias lsd='ls -d */'
alias locate1='locate -n1'
alias off='poweroff'
alias please='sudo'

function gr () {
	grep -irn --color --binary-files=without-match --exclude-dir=".svn*" $1 *
}

function pids () {
	ps -A | grep $1 | awk '{print $1}'
}

function path() {
    echo $PATH | tr : "\n"
}

function catline()
{
    if [ $# -ne 2 ]; then
        return 1
    fi

    FILE=$1
    LINE=$2
    FILE_LINES=$(wc -l $FILE | cut -d ' ' -f 1)

    if [ $LINE -gt $FILE_LINES ]; then
        return 1
    fi

    head -n $LINE $FILE | tail -n 1

    return 0
}

# Move window
function move() {
	echo -ne "\e[3;"$1";"$2"t"
}

# Get window size
function size() {
    echo "width:  $(tput cols)"
    echo "height: $(tput lines)"
}

# Resize window
function resize() {
	echo -ne "\e[8;"$2";"$1"t"
}

# Cleans ugly extensions
alias javaclean='find . -name "*.class" -delete'
alias pyclean='find . -name "*.pyc" -delete'
alias racketclean='find . -name "*.rkt\~" -delete'
alias dsstoreclean='find . -name ".DS_Store" -delete'
alias swpclean='find . -name "*.swp" -delete;find . -name "*.swo" -delete'
alias patchclean='find . -name "*.orig" -delete; find . -name "*.rej" -delete; find . -name "*.mine" -delete; find . -regextype posix-extended -regex ".*\.r[0-9]{6}" -delete'
alias cclean='find . -name "*.o" -delete; find . -name "*.dla" -delete; find . -name "*.dnm" -delete; find . -name "a.out" -delete'
function clean() {
    CD=$(pwd)
    if [[ -d $1 ]]; then
        CD=$1
    fi

    (
    cd $CD
    javaclean
    pyclean
    racketclean
    dsstoreclean
    swpclean
    patchclean
    cclean
    )
}

# When in svn directories, prepend 'svn' onto mkdir, mv, cp and rm
function mv() {
    svn mv $@ 2> /dev/null
    if [[ $? -ne 0 ]]; then
        /bin/mv $@
    fi
}
function rm() {
    svn del $@ 2> /dev/null
    if [[ $? -ne 0 ]]; then
        /bin/rm -rf $@
    fi
}
function mkdir() {
    svn mkdir $@ 2> /dev/null
    if [[ $? -ne 0 ]]; then
        /bin/mkdir $@
    fi
}
function cp() {
    svn cp $@ 2> /dev/null
    if [[ $? -ne 0 ]]; then
        /bin/cp -r $@
    fi
}

function ucsb() {
    /usr/local/pulse/pulseUi
}

# Print a bar the width of the command prompt
full_bar() {
    printf '%*s' $(($COLUMNS-12)) | tr ' ' -;printf '  %s' $(date +"%H:%M:%S")
}
# Show the git branch at command line
parse_git_branch() {
    git branch &> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Time of last command and now so we can show duration of all commands
PROMPT_COMMAND='build_ps1'

shopt -s extdebug
preexec_invoke_exec() {
    [ -n "$COMP_LINE" ] && return # do nothing if completing
    [ "$BASH_COMMAND" = "$PROMPT_COMMAND" ] && return # don't cause preexec for PROMPT_COMMAND

    # So we don't get locked accidentally
    local this_command=`HISTTIMEFORMAT= history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//"`;
    if [ "shopt -u extdebug" == "$this_command" ]; then
        return 0
    fi

    LAST_CMD_START_TIME=$(date '+%s')
}
trap 'preexec_invoke_exec' DEBUG

build_ps1() {
    RUNTIME=
    if [ ! -z $LAST_CMD_START_TIME ]; then
        LAST_CMD_END_TIME="$(date '+%s')"
        ELAPSED=$((LAST_CMD_END_TIME-LAST_CMD_START_TIME))
        LAST_CMD_START_TIME=

        printf '%*s' $(($COLUMNS)) | tr ' ' ' '
        RUNTIME="Time: $(date -d "@$ELAPSED" '+%Mm %Ss') "
    fi

    export PS1="\${RUNTIME}\n\$(full_bar)\n\W $ "
}


