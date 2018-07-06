#!/bin/bash
# First pull in global items
source ~/.bash_profile

export GHS_LINUXSERV_USE_64_BIT=1

alias cp='cp -r'
alias rm='rm -rf'

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

# When running two bash windows, allow both to write to the history, not one stomping the other
shopt -s histappend
# Keep multiline commands as one command in history
shopt -s cmdhist
# check window size after each command
shopt -s checkwinsize

# IP for ssh'ing into laptop
export LAPTOP="tmenninger@192.168.98.34"
export DESKTOP='tmenninger@192.168.1.101'
export WORKSTATION='tmenninger@willow.ghs.com'

# Gets vim packages used in vimrc
function vim_packages() {
    echo "no packages" > /dev/null
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
function clean() {
    find . -name "*.orig" -delete
    find . -name "*.rej" -delete
    find . -name "*.swp" -delete
    find . -name "*.swo" -delete
    find . -name ".DS_Store" -delete
}

alias chrome='google-chrome-stable &'
alias sourcebash='source ~/.bash_profile;source ~/.bashrc'
alias ip='ifconfig | grep ".*Bcast" | grep -o "addr:[0-9\.]*" | grep -o "[0-9\.]*"'
alias vim='stty -ixon;vim'
alias vimrc='vim ~/.vimrc'
alias bashprofile='vim ~/.bash_profile;sourcebash'
alias bashrc='vim ~/.bashrc;sourcebash'
alias aws='ssh -i ~/zonedin.pem ubuntu@13.58.184.126'
alias home='cd ~'
alias base='cd /'
alias desktop='cd ~/Desktop'
alias downloads='cd ~/Downloads'
alias javaclean='sudo find . -name "*.class" -type f -delete'
alias pyclean='sudo find . -name "*.pyc" -type f -delete'
alias racketclean='sudo find . -name "*.rkt\~" -type f -delete'
alias dsstoreclean='sudo find . -name ".DS_Store" -type f -delete'
alias ghdla='ghdl -a --ieee=synopsys -fexplicit'
alias ghdle='ghdl -e --ieee=synopsys -fexplicit'

# Make sure we have the vim packages
vim_packages

function svn_mass_propset() {
    while [[ $# -gt 0 ]];
    do
        /usr/bin/svn propset svn:mime-type text/plain $1
        /usr/bin/svn propset svn:eol-style native $1
        shift
    done
}

# Add or delete all unknowns
function svn_mass_add() {
    # Non binary files
    svn st | grep '^?' | grep -v 'Binary' | sed 's/^?\S*/svn add /g' > /tmp/svn_add_list
    source /tmp/svn_add_list
    sed -i 's/^svn add /svn propset svn:mime-type text\/plain /g' /tmp/svn_add_list
    source /tmp/svn_add_list
    sed -i 's/mime-type text\/plain/eol-style native/g' /tmp/svn_add_list
    source /tmp/svn_add_list

    # Binary files
    svn st | grep '^?' | grep 'Binary' | grep 'bmp' | sed 's/^?\S*/svn add /g' > /tmp/svn_add_list
    source /tmp/svn_add_list
    sed -i 's/^svn add /svn propset svn:mime-type application\/octet-stream /g' /tmp/svn_add_list
    source /tmp/svn_add_list

    rm /tmp/svn_add_list
}

function svn_mass_del() {
    svn st | grep '^\!' | sed 's/^\!\S*/svn del --force /g' > /tmp/svn_del_list
    source /tmp/svn_del_list
    rm /tmp/svn_del_list
}

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes
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

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Show the git branch at command line
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}
export PS1="\W\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "


