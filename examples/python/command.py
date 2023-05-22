#!/usr/bin/python3

import datetime
import subprocess

def dbg(msg):
    print("{}: {}".format(datetime.datetime.now(), msg))

def cmd(cmd, suppress_errors=False):
    dbg("running: {}".format(cmd))
    try:
        stdout = subprocess.check_output([cmd], shell=True)
    except Exception as e:
        if suppress_errors:
            print(e)
        else:
            raise

def run(cmd, suppress_errors=False):
    print('>>> {cmd}'.format(**locals()))
    p = subprocess.Popen(cmd,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.STDOUT,
                         shell=True)
    while True:
        line = p.stdout.readline().decode("utf-8").replace("\n", "")
        if not line:
            break
        print(line)

    p.communicate()
    if not suppress_errors:
        assert(p.returncode == 0)
