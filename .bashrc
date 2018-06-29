# runs on: interactive non-login shell

if [ -d "/tools/users/tmenninger" ]
then
    cp -f /home/eng/users/tmenninger/.bash_svn /opt/home/tmenninger/
fi

# get path from .profile, as .profile is used for more things than just bash
# (e.g. XFCE/GNOME alt-f2)

TOOLS_DIR=/home/multi/tools_devl/working

PATH=/home/compiler/tools_devl/working/linux64-comp:${PATH}
PATH=/home/multi/tools_devl/working/linux64-ide:${PATH}
PATH=${TOOLS_DIR}/sitescripts:${PATH}
PATH=${RTOS_DIR}/privutils/svn_commit:${PATH}
PATH=${RTOS_DIR}/privutils/gcomponent:${PATH}
PATH=${PATH}:/archive/script
PYTHONPATH=${RTOS_DIR}/privutils/gcomponent:${PYTHONPATH}
PATH=/home/multi/tools_devl/working/linux64-ide/:${PATH}
export PYTHONPATH

alias cp='cp -r'

alias ls='ls -h --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -la'

alias cls='clear; ls'
alias lsd='ls -d */'

alias locate1='locate -n1'

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

PS1="$BLD$FGRN\u$FYEL@$FRED\h$RST:$BLD$FBLU\w$RST $ "
PS2="$BLD$FGRN> $RST"

## Bash history tweaks
export HISTTIMEFORMAT=
# When running two bash windows, allow both to write to the history, not one stomping the other
shopt -s histappend
# Keep multiline commands as one command in history
shopt -s cmdhist
#export PROMPT_COMMAND="history -a"

# check window size after each command
shopt -s checkwinsize

export EDITOR=me

# GHS Specific

# Host defines.....
export GHS_LMHOST="#ghslm1,ghslm2,ghslm3"
export GHS_LMWHICH="ghs"

# SVN...
alias svnstat="svn status -q"
alias svnr="svn resolve --accept working"
alias sup="svn up --non-interactive; echo -e \"\\\\a\"; sleep .25; echo -e \"\\\\a\""
alias gbas="sup && ./builds-ep/build_all.sh"

alias svn16="/archive/subversion/1.6/subversion-1.6.9/subversion/svn/svn"
alias svn17="/archive/subversion/1.7/subversion-1.7.17/subversion/svn/svn"

# other aliases
# alias diffview='meld'
alias dv="diffview"
alias clgrep='clgrep --rtos'
alias unigui='${RTOS_DIR}/rtos_val/shared/unival/unigui.py'
# alias multi='multi -sr_private' # scottr this fails to open BSP directories
alias mpm='${TOOLS_DIR}/mprojmgr'
alias ghsgcc='${TOOLS_DIR}/gcc'
alias gc="gcomponent.py"
alias gco="gcomponent.py -o"
alias gdo="gcomponent.py -o -d"
alias gdom="gcomponent.py -o -d -m"
alias dvl="diffview -local"
alias mail="thunderbird -compose"
alias gb="gbuild"
alias mhist="me -historybrowser"
alias gba="./builds-ep/build_all.sh"
alias ba="./builds-ep/build_all.sh"
alias printsource="enscript -C -DDuplex:true -DCollate:true -G2rE -f Courier@6 --margins=20:20:15:15"
alias ivncviewer="/home/integrity/rtos_val/bin/vncviewer/linux86/vncviewer"

alias ct="ctags -R --exclude=\"INTEGRITY-docs\" --exclude=\"manuals\" --exclude=\"python\""

gr () {
	grep -irn --color --binary-files=without-match --exclude-dir=".svn*" $1 *
}
pids () {
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

function debug() {
        BSP="$(basename $(pwd))"
        BINARY="$1"

        multi "../bin/${BSP}/${BINARY}"
}

# shows last command in terminal title
# At GHS, this breaks rcp. (We use rcp in our test infrastructure to copy files
# to remote machines, for example in preparation to tftpboot a kernel)
# In BUGS section of rcp: commands in .bashrc confuse rcp
# FIXME: only works if we're rcp'ing to another machine; rcp's to this machine
#
#if [ $HOSTNAME = zaphod ]; then
#    trap 'echo -ne "\e]0;$BASH_COMMAND\007"' DEBUG
#fi

source ~/.bash_profile
