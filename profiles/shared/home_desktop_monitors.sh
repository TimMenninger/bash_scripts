#!/bin/bash

function mon1() {
    xrandr --output HDMI-2 --same-as HDMI-0
}

function mon2() {
    xrandr --output HDMI-2 --left-of HDMI-0
}

