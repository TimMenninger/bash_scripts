#!/bin/bash -l

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
alias ct="ctags -R --exclude=\"INTEGRITY-docs\" --exclude=\"manuals\" --exclude=\"python\""
alias mhist="me -historybrowser"
alias gba="./builds-ep/build_all.sh"
alias ba="./builds-ep/build_all.sh"
alias ivncviewer="/home/integrity/rtos_val/bin/vncviewer/linux86/vncviewer"

function debug() {
    BSP="$(basename $(pwd))"
    BINARY="$1"

    multi "../bin/${BSP}/${BINARY}"
}
