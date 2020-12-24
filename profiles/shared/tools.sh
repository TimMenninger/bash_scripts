#!/bin/bash -l

# IP for ssh'ing into laptop
export LAPTOP="tmenninger@192.168.98.34"
export DESKTOP='tmenninger@192.168.1.101'
export WORKSTATION='tmenninger@willow.ghs.com'

# Editor of choice
export EDITOR=vim

alias textme="/home/willow/scripts/tools/send_text.py 14846207488"
alias vim='stty -ixon;vim'
alias chrome='(google-chrome-stable &> /dev/null) &'
alias vimrc='vim ~/.vimrc'
alias sourcebash='source $BASH_PROFILE'
alias bashprofile='vim $BASH_PROFILE;sourcebash'
alias bashrc='vim $BASH_PROFILE;sourcebash'
alias home='cd ~'
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'
alias ll='ls -lah'
alias locate1='locate -n1'
alias off='poweroff'
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


