#!/bin/bash

if [ -d "/t/toolsvc/trunk/users/" ]; then
    # Whenever I check out a VM that has a tool checkout, start checking out my
    # users folder as soon as the vm starts up.
    cd /t/toolsvc/trunk/users
    svn up `whoami`
    svn up nh2017

    # Copy vimrc file
    cp /home/eng/users/tmenninger/.vimrc ~/.vimrc
fi

