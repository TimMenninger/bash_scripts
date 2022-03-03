#!/usr/bin/env /bin/bash

REMOTE_HOST=ir@irdv-tmenninger

SRC=$REMOTE_HOST:/home/ir/code
DST=/Users/tmenninger

# NOTE: only to be used from mac
if [ ! -d $DST ]; then
    echo "expect $DST to exist"
    echo "NOTE: only to be used from mac terminal"
    exit
fi

rsync -azP $SRC $DST
git -C $DST/iridium status
