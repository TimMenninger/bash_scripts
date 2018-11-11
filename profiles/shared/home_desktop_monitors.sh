#!/bin/bash

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
