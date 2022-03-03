#!/usr/bin/python3

import datetime
import os
import subprocess
import sys
import tempfile

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

CLUSTER="irp394-c07"

LINUXPATH="/code/bld_linux/1iridium/system/image/iros/linux/linux-5.15.24"
OUTIMG="/imgs/iros-5.15.24.img"
BCM_DEB="/code/bld_linux/1iridium/system/network/iridium-broadcom-kmod_2.2.33.u18_amd64.deb"

if False:
    cmd("make -j 16 LOCALVERSION='' -C {}".format(LINUXPATH))
else:
    cmd("cd /code/1iridium && ./run make -j 16 iros-kernel SELECT_KERNEL=5.15.24")
cmd("cd /code/1iridium && ./run make -j 16 SELECT_KERNEL=5.15.24 -C system/network bcm-kmod")

# TODO: 'make install' throws errors, and also generates a larger initrd than
# the real build.
chroot_script = '''#!/bin/bash
set -x
cd /tmp/linux
rm -rf /lib/modules/*

make modules_install LOCALVERSION=''
# We can ignore the errors from make install
make install LOCALVERSION=''

dpkg -i /tmp/bcm.deb
rm -rf /tmp/bcm.deb

kname=$(ls -1 /lib/modules)
depmod -a $kname

exit 0
'''

with tempfile.TemporaryDirectory() as d:
    dbg("work dir is {}".format(d))
    os.chdir(d)
    os.mkdir('iros-mount')
    os.mkdir('squashfs')
    with open('chroot.sh', 'w') as f:
        f.write(chroot_script)
    os.chmod('chroot.sh', 0o755)

    try:
        cmd('mount -t ext4 -o loop,offset=1048576 {} iros-mount'.format(OUTIMG))
        cmd('mount -t squashfs -o loop iros-mount/casperA/filesystem.squashfs squashfs')
        cmd('cp -a squashfs squashfs-rw')
        cmd('cp -a {} squashfs-rw/tmp/linux'.format(LINUXPATH))
        cmd('cp -a {} squashfs-rw/tmp/bcm.deb'.format(BCM_DEB))
        cmd('mkdir squashfs-rw/boot')
        cmd('cp chroot.sh squashfs-rw/tmp')
        cmd('chroot squashfs-rw /tmp/chroot.sh')
        cmd('mv squashfs-rw/boot .')
        cmd('rm -rf squashfs-rw/tmp/linux')
        cmd('cp {}/vmlinux squashfs-rw/vmlinux'.format(LINUXPATH))
        cmd('mksquashfs squashfs-rw new-filesystem.squashfs')
        cmd('cp boot/initrd.img* iros-mount/casperA/initrd.img')
        cmd('cp boot/vmlinuz* iros-mount/casperA/vmlinuz')
        cmd('cp new-filesystem.squashfs iros-mount/casperA/filesystem.squashfs')
        cmd('ls -l iros-mount/casperA/')
    finally:
        cmd('umount squashfs', suppress_errors=True)
        cmd('umount iros-mount', suppress_errors=True)

    print('{} is ready to go!'.format(OUTIMG))

if CLUSTER != None:
    cmd('scp {} ir@{}:~'.format(OUTIMG, CLUSTER))
