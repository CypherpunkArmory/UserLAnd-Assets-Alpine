#! /bin/bash

export ARCH_DIR=output/${1}
export ROOTFS_DIR=$ARCH_DIR/rootfs

case "$1" in
    arm) export ARCH_BOOTSTRAP_ARCH_OPT=armv7h
        export ARCH_BOOTSTRAP_QEMU_OPT=-q
        ;;
    arm64) export ARCH_BOOTSTRAP_ARCH_OPT=aarch64
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

# APK Tool
MIRROR=http://dl-5.alpinelinux.org/alpine
ARCH=$1
CHROOT=alpine-chroot-newest
VERSION=latest-stable
APK_TOOL=apk-tools-static-2.10.1-r0.apk

rm -rf $ARCH_DIR
mkdir -p $ARCH_DIR
rm -rf $ROOTFS_DIR
mkdir -p $ROOTFS_DIR

# Start Building Alpine

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

LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR apk add sudo dropbear tigervnc xterm xorg-twm expect

echo "127.0.0.1 localhost" > $ROOTFS_DIR/etc/hosts
echo "nameserver 8.8.8.8" > $ROOTFS_DIR/etc/resolv.conf
echo "nameserver 8.8.4.4" >> $ROOTFS_DIR/etc/resolv.conf

cp scripts/shrinkRootfs.sh $ROOTFS_DIR
chmod 777 $ROOTFS_DIR/shrinkRootfs.sh
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR ./shrinkRootfs.sh
rm $ROOTFS_DIR/shrinkRootfs.sh

tar --exclude='dev/*' --exclude='etc/mtab' -czvf $ARCH_DIR/rootfs.tar.gz -C $ROOTFS_DIR .

LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR apk add base-devel

#build disableselinux to go with this release
cp scripts/disableselinux.c $ROOTFS_DIR
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR gcc -shared -fpic disableselinux.c -o libdisableselinux.so
cp $ROOTFS_DIR/libdisableselinux.so $ARCH_DIR/libdisableselinux.so

# BUSY BOX COMES WITH ALPINE
#LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR apk add busybox
#cp $ROOTFS_DIR/bin/busybox $ARCH_DIR/busybox