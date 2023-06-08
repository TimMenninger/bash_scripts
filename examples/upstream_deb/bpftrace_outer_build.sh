#!/usr/bin/bash


#################################################################################
####
#### For some reason build container binds /usr/src from build host to
#### /usr/src inside the container. The volume is bound as read-only which
#### makes it hard to install built packages that adds files to this directory.
#### In particular `googletest` framewark wants to store files in this directory.
#### To work around this problem, we create a chrooted environment and use it to
#### build and install all the needed packages.
####
#### When done, one needs to install bpftrace and its runtime dependencies
#### on FB blade. No need to install build time dependencies if one wants to
#### to run bpftrace.
####   
#################################################################################

set -xe

## Create build chroot environment.
export CHROOT=/tmp/bpftrace-chroot
export DISTRIB_CODENAME=bionic
export DATECODE=20201012

export MIRROR="http://c14-apt-svc.dev.purestorage.com/${DISTRIB_CODENAME}/${DISTRIB_CODENAME}-${DATECODE}/"

sudo rm -rf $CHROOT; sudo mkdir -p $CHROOT    
sudo debootstrap --arch=amd64 --verbose $DISTRIB_CODENAME $CHROOT $MIRROR

# Make it chrootable.
sudo mount --bind /dev  ${CHROOT}/dev
sudo mount --bind /dev/pts  ${CHROOT}/dev/pts
sudo mount --bind /proc ${CHROOT}/proc
sudo mount --bind /sys  ${CHROOT}/sys

## Deploy build script and patches in chrooted environment
tar -C ${CHROOT} -xf patches.tar

## Run build
sudo chroot ${CHROOT} bash /build/scripts/build.sh

# Cleanup
sudo umount -f ${CHROOT}/sys
sudo umount -f ${CHROOT}/proc
sudo umount -f ${CHROOT}/dev/pts
sudo umount -f ${CHROOT}/dev


### Packages to install on blade

# sudo apt-get install -y -f $CHROOT/libbpf/libbpf0_0.5.0-1_amd64.deb
# sudo apt-get install -y -f $CHROOT/llvm-toolchain/libllvm11_11.1.0-6_amd64.deb
# sudo apt-get install -y -f $CHROOT/llvm-toolchain/libclang1-11_11.1.0-6_amd64.deb
# sudo apt-get install -y -f $CHROOT/bpfcc/libbpfcc*
# sudo apt-get install -y -f $CHROOT/bpftrace/bpftrace_0.14.0-1_amd64.deb

