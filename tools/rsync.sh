#!/usr/bin/env /bin/bash

SRC=$1
DST=$2

if [ -z "$DST" ]; then
    echo "usage: rsync.sh [SOURCE] [DESTINATION]"
    return 1
fi

rsync -azP $SRC $DST
