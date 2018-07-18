alias svnforce='/usr/bin/svn'

function n64() {
    mupen64plus /usr/n64/$1.n64
}

function ps2() {
    game=""
    if ! [ -z "$1" ]
    then
        game=/usr/ps2/$1.iso
    fi
    PCSX2 --fullscreen $game
}

function mon1() {
    xrandr --output HDMI-0 --mode 1600x1200
    xrandr --output DVI-D-0 --same-as HDMI-0 --output HDMI-2 --same-as HDMI-0
}

function mon2() {
    xrandr --output DVI-D-0 --left-of HDMI-2 --output HDMI-0 --same-as HDMI-2
}

function mon3() {
    xrandr --output DVI-D-0 --left-of HDMI-2 --output HDMI-2 --left-of HDMI-0
}

alias zonedin='cd /home/tmenninger/zonedin'
alias ps2Ctrlr='sudo xboxdrv --detach-kernel-driver --led 2'
alias off='poweroff'
