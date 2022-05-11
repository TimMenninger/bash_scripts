#!/usr/bin/python3

import os
import re
import shutil
import subprocess
import sys
import tempfile

SSH_IRP_HISTORY = os.path.join(os.path.expanduser("~"), ".ssh_irp_history")

# Make sure file exists
with open(SSH_IRP_HISTORY, "a+"):
    pass

# Only intercept when we go to a cluster. Doing this the dumb way and assuming
# first argument is host
for arg in sys.argv:
    show = arg == "--show"
    match = re.search("irp\d\d\d-c0\d[^\s:]*", arg)
    if match or show:
        # Get history to either print or modify
        with open(SSH_IRP_HISTORY, "r") as f:
            history = [ line.strip() for line in f.readlines() ]

        # Print if showing, or modify if matching a cluster name
        if show:
            [ print(line.strip()) for line in history ]
            sys.exit(0)
        elif match:
            history.append(match.group())
            idx = history.index(match.group())
            if idx != len(history)-1:
                history = history[:idx] + history[idx+1:]

            with tempfile.NamedTemporaryFile(delete=False) as tmp:
                [ tmp.write(bytes("{}\n".format(item), "UTF-8")) for item in history ]
                tempname = tmp.name

            shutil.move(tmp.name, SSH_IRP_HISTORY)

subprocess.call(sys.argv, shell=True)
