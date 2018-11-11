#!/bin/bash -l

function ps2() {
    game=""
    if ! [ -z "$1" ]
    then
        game=/usr/ps2/$1.iso
    fi
    PCSX2 --fullscreen $game
}

alias ps2Ctrlr='sudo xboxdrv --detach-kernel-driver --led 2'
