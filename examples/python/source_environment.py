#!/usr/bin/env python

import os
import pprint
import shlex
import subprocess

command = shlex.split("env -i bash -c 'source init_env && env'")
proc = subprocess.Popen(command, stdout = subprocess.PIPE)
for line in proc.stdout:
    (key, _, value) = line.partition("=")
    os.environ[key] = value
proc.communicate()

pprint.pprint(dict(os.environ))
