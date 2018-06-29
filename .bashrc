#!/bin/bash

# First pull in global items
source ~/.bash_profile

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

# When running two bash windows, allow both to write to the history, not one stomping the other
shopt -s histappend
# Keep multiline commands as one command in history
shopt -s cmdhist
# check window size after each command
shopt -s checkwinsize

# IP for ssh'ing into laptop
export LAPTOP="tmenninger@192.168.98.34"

# Gets vim packages used in vimrc
function vim_packages() {
    STARTING_DIR=$(pwd)

    # Make sure there is a bundle and .vim directory
    ls ~/.vim 2>/dev/null >/dev/null
    if [ $? -ne 0 ];
    then
        mkdir ~/.vim
    fi
    ls ~/.vim/bundle 2>/dev/null >/dev/null
    if [ $? -ne 0 ];
    then
        mkdir ~/.vim/bundle
    fi

    # CtrlP
    ls ~/.vim/bundle/ctrlp.vim 2>/dev/null >/dev/null
    if [ $? -ne 0 ];
    then
        git clone https://github.com/ctrlpvim/ctrlp.vim.git ~/.vim/bundle/ctrlp.vim
        cd ~/.vim/bundle/ctrlp-cmatcher
        ./install.sh
    fi
    # CtrlP extension
    ls ~/.vim/bundle/ctrlp-cmatcher.vim 2>/dev/null >/dev/null
    if [ $? -ne 0 ];
    then
        git clone https://github.com/jazzcore/ctrlp-cmatcher ~/.vim/bundle/ctrlp-cmatcher.vim
    fi
    # CommandT
    ls ~/.vim/bundle/command-t.vim 2>/dev/null >/dev/null
    if [ $? -ne 0 ];
    then
        git clone https://github.com/wincent/Command-T ~/.vim/bundle/command-t.vim
    fi
    # Multiple cursors
    ls ~/.vim/bundle/vim-multiple-cursors.vim 2>/dev/null >/dev/null
    if [ $? -ne 0 ];
    then
        git clone https://github.com/terryma/vim-multiple-cursors.git ~/.vim/bundle/vim-multiple-cursors.vim
    fi
    # Highlight and surround with braces
    ls ~/.vim/bundle/vim-surround.vim 2>/dev/null >/dev/null
    if [ $? -ne 0 ];
    then
        git clone https://github.com/tpope/vim-surround.git ~/.vim/bundle/vim-surround.vim
    fi
    # Switch between header and source files
    ls ~/.vim/bundle/CurtineIncSw.vim 2>/dev/null >/dev/null
    if [ $? -ne 0 ];
    then
        git clone https://github.com/ericcurtin/CurtineIncSw.vim ~/.vim/bundle/CurtineIncSw.vim
    fi

    # Go back to starting directory
    cd $STARTING_DIR
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
    svn st | grep '^?' | grep 'Binary' | sed 's/^?\S*/svn add /g' > /tmp/svn_add_list
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


