#!/bin/bash -l

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

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
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
