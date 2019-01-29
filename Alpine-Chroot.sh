#! /bin/bash

export ARCH_DIR=output/${1}
export ROOTFS_DIR=$ARCH_DIR/rootfs

case "$1" in
    armhf) export ARCH_BOOTSTRAP_ARCH_OPT=armv7h
        export ARCH_BOOTSTRAP_QEMU_OPT=-q
        ;;
    aarch64) export ARCH_BOOTSTRAP_ARCH_OPT=aarch64
        export ARCH_BOOTSTRAP_QEMU_OPT=-q
        ;;
    x86) export ARCH_BOOTSTRAP_ARCH_OPT=i686
        ;;
    x86_64) export ARCH_BOOTSTRAP_ARCH_OPT=x86_64
        ;;
    all) exit
        ;;
    *) echo "unsupported arch"
        exit
        ;;
esac

MIRROR=http://dl-5.alpinelinux.org/alpine
ARCH=$1
CHROOT=alpine-chroot-newest
VERSION=latest-stable
APK_TOOL=apk-tools-static-2.10.1-r0.apk

if [ -d $CHROOT ]
then
    echo "$CHROOT already exists."
    exit 0
else
    mkdir -p $CHROOT
fi

wget $MIRROR/$VERSION/main/$ARCH/$APK_TOOL
tar -xzf $APK_TOOL
./sbin/apk.static \
    -X $MIRROR/$VERSION/main \
    -U \
    --allow-untrusted \
    --root ././$CHROOT \
    --initdb add alpine-base alpine-sdk

cp /etc/resolv.conf $CHROOT/etc/
echo "$MIRROR/$VERSION/main" >  $CHROOT/etc/apk/repositories

# Cleaning up
rm -rf sbin
rm -f APK_TOOL

echo " "
echo "Your Alpine Linux installation in '$CHROOT' is ready now."
echo "To start Alpine:"
echo "sudo chroot $CHROOT /bin/sh -l"
echo " "
