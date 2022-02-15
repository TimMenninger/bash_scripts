#! /usr/bin/python3

import os
import pexpect
import re
import sys
import time

SUDO_PW = os.getenv("SUDO_PW")
VPN_PW1 = os.getenv("VPN_PW1")
VPN_PW2 = os.getenv("VPN_PW2")

child = pexpect.spawn("ps -aux")
found = True
try:
    child.expect("vpn_sign_in", timeout=2)
except:
    found = False

if found:
    print("Already running somewhere")
    exit()

if type(SUDO_PW) == type(None):
    print("set SUDO_PW")
    exit()
if type(VPN_PW1) == type(None):
    print("set VPN_PW1")
    exit()
if type(VPN_PW2) == type(None):
    print("set VPN_PW2")
    exit()

while True:
    child = pexpect.spawn("sudo vpnc-disconnect")
    try:
        child.expect_exact("[sudo] password for tmenninger: ", timeout=1)
        child.sendline("{}".format(SUDO_PW))
    except:
        print("Didn't see enter password for disconnect")
    child.expect(pexpect.EOF)

    child = pexpect.spawn("sudo vpnc-connect ghs")
    try:
        child.expect_exact("[sudo] password for tmenninger: ", timeout=1)
        child.sendline("{}".format(SUDO_PW))
    except:
        print("Didn't see enter password for connect")

    child.expect_exact("Enter password for tmenninger@vpn-gw.ghs.com: ", timeout=5)
    child.sendline("{}".format(VPN_PW1))

    child.expect_exact("Password for VPN tmenninger@206.169.158.26: ", timeout=60)
    child.sendline("{}".format(VPN_PW2))

    child.expect(pexpect.EOF)

    time.sleep(60*60*12)

