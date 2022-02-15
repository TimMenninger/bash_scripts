#!/bin/bash -l

# IP for ssh'ing into laptop

# Stupid keyboard can't tilde
export TD=~

# Editor of choice
export EDITOR=vim

alias scripts='cd $HOME/scripts'
alias vim='stty -ixon;vim'
alias vimrc='vim ~/.vimrc'
alias sourcebash='source $BASH_PROFILE'
alias bashprofile='vim $BASH_PROFILE;sourcebash'
alias bashrc='vim $BASH_PROFILE;sourcebash'
alias home='cd ~'
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'
alias ll='ls -lah'
alias please='sudo !!'

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
    /bin/mv $@
}
function rm() {
    /bin/rm -rf $@
}
function mkdir() {
    /bin/mkdir -p $@
}
function cp() {
    /bin/cp -rP $@
}

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes
if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
export COLOR_AUTO=""
if [ -x /usr/bin/dircolors ]; then
    export COLOR_AUTO="--color=auto"
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

### Terminal Prompt
# fancy colors for our prompt
RST="\[\e[0m\]"   # reset
BLD="\[\e[1m\]"   # hicolor
UNL="\[\e[4m\]"   # underline
INV="\[\e[7m\]"   # inverse background and foreground
FBLK="\[\e[30m\]" # foreground black
FRED="\[\e[31m\]" # foreground red
FGRN="\[\e[32m\]" # foreground green
FYEL="\[\e[33m\]" # foreground yellow
FBLU="\[\e[34m\]" # foreground blue
FMAG="\[\e[35m\]" # foreground magenta
FCYN="\[\e[36m\]" # foreground cyan
FWHT="\[\e[37m\]" # foreground white
BBLK="\[\e[40m\]" # background black
BRED="\[\e[41m\]" # background red
BGRN="\[\e[42m\]" # background green
BYEL="\[\e[43m\]" # background yellow
BBLU="\[\e[44m\]" # background blue
BMAG="\[\e[45m\]" # background magenta
BCYN="\[\e[46m\]" # background cyan
BWHT="\[\e[47m\]" # background white

# When running two bash windows, allow both to write to the history, not one stomping the other
shopt -s histappend
# Keep multiline commands as one command in history
shopt -s cmdhist
# check window size after each command
shopt -s checkwinsize

# Time of last command and now so we can show duration of all commands
PROMPT_COMMAND='build_ps1'

shopt -s extdebug
preexec_invoke_exec() {
    [ -n "$COMP_LINE" ] && return # do nothing if completing
    [ ":" == "$BASH_COMMAND" ] && return
    [ "tr ' ' -" == "$BASH_COMMAND" ] && return
    [ "$BASH_COMMAND" == "$PROMPT_COMMAND" ] && return

    # So we don't get locked accidentally
    local this_command=`HISTTIMEFORMAT= history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//"`;
    [ "shopt -u extdebug" == "$this_command" ] && return

    # Store time
    if [ -z $LAST_CMD_START_TIME ]; then
        LAST_CMD_START_TIME=$(date '+%s')
    fi
}
trap 'preexec_invoke_exec' DEBUG

build_ps1() {
    RUNTIME=
    if [ ! -z $LAST_CMD_START_TIME ]; then
        LAST_CMD_END_TIME="$(date '+%s')"
        ELAPSED=$((LAST_CMD_END_TIME-LAST_CMD_START_TIME))
        unset LAST_CMD_START_TIME

        ((SECS=$ELAPSED%60))
        ((MINS=($ELAPSED/60)%60))
        ((HOURS=($ELAPSED/60/60)%24))
        ((DAYS=$ELAPSED/60/60/24))

        TIME_STR="${SECS}s"
        if [ $MINS != 0 ]; then
            TIME_STR="${MINS}m $TIME_STR"
        fi
        if [ $HOURS != 0 ]; then
            if [ $MINS == 0 ]; then
                TIME_STR="${MINS}m $TIME_STR"
            fi
            TIME_STR="${HOURS}h $TIME_STR"
        fi
        if [ $DAYS != 0 ]; then
            if [ $HOURS == 0 ]; then
                if [ $MINS == 0 ]; then
                    TIME_STR="${MINS}m $TIME_STR"
                fi
                TIME_STR="${HOURS}h $TIME_STR"
            fi
            TIME_STR="${DAYS}d $TIME_STR"
        fi


        printf '%*s' $(($COLUMNS)) | tr ' ' ' '
        RUNTIME="Time: $TIME_STR "
    fi

    # Print a bar the width of the command prompt
    FULL_BAR=$(printf '%*s' $(($COLUMNS-12)) | tr ' ' -;printf '  %s' $(date +"%H:%M:%S"))

    export PS1="\${RUNTIME}\n\${FULL_BAR}\n\W $ "
}

function abspath {
  (cd "$(dirname '$1')" &>/dev/null && printf "%s/%s" "$PWD" "${1##*/}")
}
