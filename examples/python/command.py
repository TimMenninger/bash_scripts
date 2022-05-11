#!/usr/bin/python3

import datetime
import subprocess

def dbg(msg):
    print("{}: {}".format(datetime.datetime.now(), msg))

def cmd(cmd, suppress_errors=False):
    dbg("running: {}".format(cmd))
    try:
        subprocess.check_call([cmd], shell=True)
    except Exception as e:
        if suppress_errors:
            print(e)
        else:
            raise
