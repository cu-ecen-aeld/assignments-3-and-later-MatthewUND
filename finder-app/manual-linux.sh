#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$1
	echo "Using passed directory ${OUTDIR} for output"
fi

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here
    #  Deep Clean on kernel tree  */
    echo "MOOPS make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} mrproper

    #  Configure the kernel build  */
    echo "make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig

    #  Build the kernel image  */
    echo "make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all"
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all  

    #  Build kernel modules  */
    echo "make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} modules

    #  Build the devicetree  */
    echo "make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} dtbs
fi

echo "Adding the Image in outdir"

cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories
mkdir -p ${OUTDIR}/rootfs
cd ${OUTDIR}/rootfs
echo "mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var  "
echo "mkdir -p usr/bin usr/sbin usr/lib"
echo "mkdir -p var/log"
mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
mkdir -p usr/bin usr/sbin usr/lib
mkdir -p var/log

echo "cd ${OUTDIR}"
cd "$OUTDIR"
if [ ! -d "${OUTDIR}/busybox" ]
then
    echo "git clone git://busybox.net/busybox.git"
    git clone git://busybox.net/busybox.git
    echo "cd busybox"
    cd busybox
    echo "git checkout ${BUSYBOX_VERSION}"
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox
    echo "make distclean"
    make distclean
    echo "make defconfig"
    make defconfig
    echo "make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}"
    make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
else
    echo "cd busybox"
    cd busybox
fi

# TODO: Make and install busybox
echo "make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE={CROSS_COMPILE} install"
make CONFIG_PREFIX=${OUTDIR}/rootfs ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

echo "Library dependencies"
echo "${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep \"program interpreter\""
${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "program interpreter"
echo "${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep \"Shared library\""
${CROSS_COMPILE}readelf -a ${OUTDIR}/rootfs/bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
SYSROOT=$(${CROSS_COMPILE}gcc -print-sysroot)
ls -al ${SYSROOT}
echo ${SYSROOT}
cp ${SYSROOT}/lib/ld-linux-aarch64.so.1 ${OUTDIR}/rootfs/lib
cp ${SYSROOT}/lib64/libm.so.6 ${OUTDIR}/rootfs/lib64
cp ${SYSROOT}/lib64/libresolv.so.2 ${OUTDIR}/rootfs/lib64
cp ${SYSROOT}/lib64/libc.so.6 ${OUTDIR}/rootfs/lib64 

# TODO: Make device nodes
echo "cd ${OUTDIR}/rootfs" 
cd "${OUTDIR}/rootfs"
echo "sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3"
echo "sudo mknod -m 600 ${OUTDIR}/rootfs/dev/console c 5 1"
sudo mknod -m 666 ${OUTDIR}/rootfs/dev/null c 1 3
sudo mknod -m 600 ${OUTDIR}/rootfs/dev/console c 5 1

# TODO: Clean and build the writer utility
cd ${FINDER_APP_DIR}
make clean
make CROSS_COMPILE=${CROSS_COMPILE}

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
sudo cp ${FINDER_APP_DIR}/fin* ${OUTDIR}/rootfs/home
sudo cp ${FINDER_APP_DIR}/writ* ${OUTDIR}/rootfs/home 
sudo cp ${FINDER_APP_DIR}/autorun-qemu.sh ${OUTDIR}/rootfs/home
sudo cp -rL ${FINDER_APP_DIR}/conf ${OUTDIR}/rootfs/home

# TODO: Chown the root directory
cd ${OUTDIR}/rootfs
sudo chown -R root:root *

# TODO: Create initramfs.cpio.gz
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
gzip -f ${OUTDIR}/initramfs.cpio
#
#
#
#
#
#
#
#
#
