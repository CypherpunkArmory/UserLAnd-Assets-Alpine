#! /bin/bash

export ARCH_DIR=output/${1}
export ROOTFS_DIR=$ARCH_DIR/rootfs

case "$1" in
    arm) export ALPINE_ARCH=armhf
        ;;
    arm64) export ALPINE_ARCH=aarch64
        ;;
    x86) export ALPINE_ARCH=x86
        ;;
    x86_64) export ALPINE_ARCH=x86_64
        ;;
    all) exit
        ;;
    *) echo "unsupported arch"
        exit
        ;;
esac

# APK Tool
MIRROR=http://dl-5.alpinelinux.org/alpine
VERSION=latest-stable
APK_TOOL=apk-tools-static-2.10.3-r1.apk

rm -rf $ARCH_DIR
mkdir -p $ARCH_DIR
rm -rf $ROOTFS_DIR
mkdir -p $ROOTFS_DIR

# Get Base Alpine Unpacked
wget -P $ARCH_DIR $MIRROR/$VERSION/main/$ALPINE_ARCH/$APK_TOOL
tar -xzf $ARCH_DIR/$APK_TOOL -C $ARCH_DIR
$ARCH_DIR/sbin/apk.static \
    -X $MIRROR/$VERSION/main \
    -U \
    --allow-untrusted \
    --root $ROOTFS_DIR \
    --initdb add alpine-base alpine-sdk sudo 

# Set Resolv.conf
echo "127.0.0.1 localhost" > $ROOTFS_DIR/etc/hosts
echo "nameserver 8.8.8.8" > $ROOTFS_DIR/etc/resolv.conf
echo "nameserver 8.8.4.4" >> $ROOTFS_DIR/etc/resolv.conf
echo "$MIRROR/$VERSION/main" >  $ROOTFS_DIR/etc/apk/repositories

# Copy down qemu files if needed
case "$1" in
    arm) cp /usr/bin/qemu-arm-static $ROOTFS_DIR/usr/bin/
        ;;
    arm64) cp /usr/bin/qemu-aarch64-static $ROOTFS_DIR/usr/bin/
        ;;
    *)  ;;
esac

#Install packages that we will need in UserLAnd
echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> $ROOTFS_DIR/etc/apk/repositories
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR apk update
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR apk add bash sudo dropbear mesa-gl x11vnc xterm twm expect shadow

#Put in place a profile.d script to setup some basic things
echo "#!/bin/sh" > $ROOTFS_DIR/etc/profile.d/userland.sh
echo "unset LD_PRELOAD" >> $ROOTFS_DIR/etc/profile.d/userland.sh
echo "unset LD_LIBRARY_PATH" >> $ROOTFS_DIR/etc/profile.d/userland.sh
echo "export LIBGL_ALWAYS_SOFTWARE=1" >> $ROOTFS_DIR/etc/profile.d/userland.sh
chmod +x $ROOTFS_DIR/etc/profile.d/userland.sh

# Shrink Rootfs
cp scripts/shrinkRootfs.sh $ROOTFS_DIR
chmod 777 $ROOTFS_DIR/shrinkRootfs.sh
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR ./shrinkRootfs.sh
rm $ROOTFS_DIR/shrinkRootfs.sh

# Save off what we have so far
tar --exclude='dev/*' --exclude='etc/mtab' -czvf $ARCH_DIR/rootfs.tar.gz -C $ROOTFS_DIR .

# Build disableselinux to go with this release
cp scripts/disableselinux.c $ROOTFS_DIR
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR gcc -shared -fpic disableselinux.c -o libdisableselinux.so
cp $ROOTFS_DIR/libdisableselinux.so $ARCH_DIR/libdisableselinux.so

# Install and copy busybox
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR apk add busybox-static
cp $ROOTFS_DIR/bin/busybox.static $ARCH_DIR/busybox
