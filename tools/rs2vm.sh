#!/usr/bin/env /bin/bash -l

REMOTE_HOST=ir@irdv-tmenninger

SRC=/Users/tmenninger/code/ir-tmenninger
DST=$REMOTE_HOST:/home/ir/code

# NOTE: only to be used from mac
if [ ! -d $SRC ]; then
    echo "expect $SRC to exist"
    echo "NOTE: only to be used from mac terminal"
    return 1
fi

rsync -azP --exclude=.git/ $SRC $DST
