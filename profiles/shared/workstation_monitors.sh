#!/bin/bash

MON_TOP_LEFT="DP-1"
MON_TOP_RIGHT="DP-3"
MON_BOTLEFT="DP-4"
MON_BOTRIGHT="DP-6"
MON_RESOLUTION="3840x2160"

function set_displays() {
    # Make all outputs outputable with resolution
    CMD_1_TOP_LT="--output $MON_TOP_LEFT  --mode $MON_RESOLUTION --above $MON_BOTLEFT  --left-of $MON_TOP_RIGHT"
    CMD_2_TOP_RT="--output $MON_TOP_RIGHT --mode $MON_RESOLUTION --above $MON_BOTRIGHT"
    CMD_3_BOT_LT="--output $MON_BOTLEFT  --mode $MON_RESOLUTION                    --left-of $MON_BOTRIGHT"
    CMD_4_BOT_RT="--output $MON_BOTRIGHT --mode $MON_RESOLUTION"

    # The final command
    xrandr $CMD_1_TOP_LT $CMD_2_TOP_RT $CMD_3_BOT_LT $CMD_4_BOT_RT
}

alias fix_monitors='set_displays'
