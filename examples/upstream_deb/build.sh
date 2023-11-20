#################################################################################
####    Inner build script
####
####    The script is expected to run inside chrooted environment
####    to build bpftrace build and runtime dependencies.
####
####    bpftrace (0.14.0-1) 'jammy'
####       - clang-11 (1:11.1.0-6) 'jammy'
####       - libbpfcc-dev (0.18.0+ds-2) 'jammy'
####           - libbpf (0.5.0-1) 'jammy'
####       - libgmock-dev/libgtest-dev (1.11.0-3) 'jammy'
####   
#################################################################################


set -xe


## Setup APT lists.
cat > /etc/apt/sources.list <<EOF
deb http://c14-apt-svc.dev.purestorage.com/bionic/bionic-20201012 bionic main
deb http://c14-apt-svc.dev.purestorage.com/bionic/bionic-20201012 bionic universe
deb http://c14-apt-svc.dev.purestorage.com/bionic/bionic-20201012 bionic multiverse
EOF

## We need to specify locale to avoid build warnings       
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen; locale-gen

## Install build dependencies that we can pull bionic
apt-get -y update
apt-get -y install debhelper wget asciidoc asciidoctor bison cmake chrpath texinfo \
            sharutils libffi-dev patchutils diffstat python3-dev libedit-dev swig \
            python3-six python3-sphinx binutils-dev libxml2-dev libjsoncpp-dev lcov \
            help2man g++-multilib libjs-mathjax python3-recommonmark doxygen gfortran \
            ocaml-nox libctypes-ocaml-dev dh-exec dh-ocaml libpfm4-dev python3-setuptools \
            libz3-dev flex arping clang-format quilt pkg-kde-tools ethtool iperf libelf-dev \
            libclang-dev libzip-dev llvm-dev libluajit-5.1-dev luajit python3-netaddr \
            python3-pyroute2 libcereal-dev

#################################################################################
####           Build and install Google C++ test framework
#################################################################################
export GOOGLETEST_WDIR=/build/wdir/googletest
export GOOGLETEST_PATCHES=/build/patches/googletest

rm -rf $GOOGLETEST_WDIR
mkdir -p $GOOGLETEST_WDIR
cd $GOOGLETEST_WDIR

wget http://c14-apt-svc.dev.purestorage.com/jammy/jammy-20220823/pool/universe/g/googletest/googletest_1.11.0-3.dsc
wget http://c14-apt-svc.dev.purestorage.com/jammy/jammy-20220823/pool/universe/g/googletest/googletest_1.11.0.orig.tar.gz
wget http://c14-apt-svc.dev.purestorage.com/jammy/jammy-20220823/pool/universe/g/googletest/googletest_1.11.0-3.debian.tar.xz
rm -rf .pc googletest-1.11.0; tar xf *orig*; tar -C googletest-1.11.0 -xf *debian*
QUILT_PATCHES=${GOOGLETEST_PATCHES} quilt push -a

(cd googletest-1.11.0; dpkg-buildpackage -us -uc --no-sign)

apt-get install -y -f $GOOGLETEST_WDIR/*.deb

#################################################################################
####       Download linux headers for 5.15 kernel (linux-libc-dev)
#################################################################################
export LINUX_LIBC_DEV_WDIR=/build/wdir/linux-libc-dev

rm -rf $LINUX_LIBC_DEV_WDIR
mkdir -p $LINUX_LIBC_DEV_WDIR
cd $LINUX_LIBC_DEV_WDIR
wget http://security.ubuntu.com/ubuntu/pool/main/l/linux/linux-libc-dev_5.15.0-46.49_amd64.deb
apt-get install -y -f $LINUX_LIBC_DEV_WDIR/linux-libc-dev_5.15.0-46.49_amd64.deb


#################################################################################
####                      LIBBPF Packages
#################################################################################

export LIBBPF_WDIR=/build/wdir/libbpf
export LIBBPF_PATCHES=/build/patches/libbpf

rm -rf $LIBBPF_WDIR; mkdir -p $LIBBPF_WDIR; cd $LIBBPF_WDIR

wget http://archive.ubuntu.com/ubuntu/pool/main/libb/libbpf/libbpf_0.5.0-1.dsc
wget http://archive.ubuntu.com/ubuntu/pool/main/libb/libbpf/libbpf_0.5.0.orig.tar.gz
wget http://archive.ubuntu.com/ubuntu/pool/main/libb/libbpf/libbpf_0.5.0-1.debian.tar.xz
rm -rf .pc libbpf-0.5.0/; tar xf *orig*; tar -C libbpf-0.5.0 -xf *debian*

QUILT_PATCHES=$LIBBPF_PATCHES quilt push -a
(cd libbpf-0.5.0; dpkg-buildpackage -us -uc --no-sign)
ls -ld $LIBBPF_WDIR/libbpf*.deb

apt-get install -y -f $LIBBPF_WDIR/libbpf*.deb

#################################################################################
####                          BPFCC Packages
#################################################################################
export BPFCC_WDIR=/build/wdir/bpfcc
export BPFCC_PATCHES=/build/patches/bpfcc

rm -rf $BPFCC_WDIR; mkdir -p $BPFCC_WDIR; cd $BPFCC_WDIR

wget http://archive.ubuntu.com/ubuntu/pool/universe/b/bpfcc/bpfcc_0.18.0+ds-2.dsc
wget http://archive.ubuntu.com/ubuntu/pool/universe/b/bpfcc/bpfcc_0.18.0+ds.orig.tar.xz
wget http://archive.ubuntu.com/ubuntu/pool/universe/b/bpfcc/bpfcc_0.18.0+ds-2.debian.tar.xz
rm -rf .pc bcc-0.18.0; tar xf *orig*; tar -C bcc-0.18.0 -xf *debian*
QUILT_PATCHES=$BPFCC_PATCHES quilt push -a
(cd bcc-0.18.0; dpkg-buildpackage -us -uc --no-sign)
ls -l $BPFCC_WDIR/libbpfcc*.deb
apt-get install -y -f $BPFCC_WDIR/libbpfcc*.deb


#################################################################################
####                     LLVM-TOOLCHAIN Packages
#################################################################################

export LLVM_TOOLCHAIN_WDIR=/build/wdir/llvm-toolchain

rm -rf $LLVM_TOOLCHAIN_WDIR; mkdir -p $LLVM_TOOLCHAIN_WDIR; cd $LLVM_TOOLCHAIN_WDIR

wget http://archive.ubuntu.com/ubuntu/pool/universe/l/llvm-toolchain-11/llvm-toolchain-11_11.1.0-6.dsc
wget http://archive.ubuntu.com/ubuntu/pool/universe/l/llvm-toolchain-11/llvm-toolchain-11_11.1.0.orig.tar.xz
wget http://archive.ubuntu.com/ubuntu/pool/universe/l/llvm-toolchain-11/llvm-toolchain-11_11.1.0-6.debian.tar.xz
rm -rf .pc llvm-toolchain-11_11.1.0; tar xf *orig*; tar -C llvm-toolchain-11_11.1.0 -xf *debian*

# No paches needed
(cd llvm-toolchain-11_11.1.0; dpkg-buildpackage -us -uc --no-sign)

apt-get install -y -f $LLVM_TOOLCHAIN_WDIR/libllvm11_11.1.0-6_amd64.deb
apt-get install -y -f $LLVM_TOOLCHAIN_WDIR/libclang-common-11-dev_11.1.0-6_amd64.deb
apt-get install -y -f $LLVM_TOOLCHAIN_WDIR/libclang-cpp11_11.1.0-6_amd64.deb
apt-get install -y -f $LLVM_TOOLCHAIN_WDIR/libclang-cpp11-dev_11.1.0-6_amd64.deb

apt-get install -y -f $LLVM_TOOLCHAIN_WDIR/llvm-*.deb
apt-get install -y -f $LLVM_TOOLCHAIN_WDIR/libclang*.deb
apt-get install -y -f $LLVM_TOOLCHAIN_WDIR/clang*.deb


#################################################################################
####                    BPFTRACE Package
#################################################################################

export BPFTRACE_WDIR=/build/wdir/bpftrace
export BPFTRACE_PATCHES=/build/patches/bpftrace

rm -rf $BPFTRACE_WDIR; mkdir -p $BPFTRACE_WDIR; cd $BPFTRACE_WDIR

wget http://archive.ubuntu.com/ubuntu/pool/universe/b/bpftrace/bpftrace_0.14.0-1.dsc
wget http://archive.ubuntu.com/ubuntu/pool/universe/b/bpftrace/bpftrace_0.14.0.orig.tar.gz
wget http://archive.ubuntu.com/ubuntu/pool/universe/b/bpftrace/bpftrace_0.14.0-1.debian.tar.xz
rm -rf .pc bpftrace-0.14.0 ; tar xf *orig*; tar -C bpftrace-0.14.0 -xf *debian*

QUILT_PATCHES=$BPFTRACE_PATCHES quilt push -a
(cd bpftrace-0.14.0; dpkg-buildpackage -us -uc --no-sign)

