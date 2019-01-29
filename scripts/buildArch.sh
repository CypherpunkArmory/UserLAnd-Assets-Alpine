#! /bin/bash

export ARCH_DIR=output/${1}
export ROOTFS_DIR=$ARCH_DIR/rootfs

case "$1" in
    armhf) export ALPINE_ARCH=armv7h
        ;;
    aarch64) export ALPINE_ARCH=aarch64
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
APK_TOOL=apk-tools-static-2.10.1-r0.apk

rm -rf $ARCH_DIR
mkdir -p $ARCH_DIR
rm -rf $ROOTFS_DIR
mkdir -p $ROOTFS_DIR

# Start Building Alpine

wget $MIRROR/$VERSION/main/$ALPINE_ARCH/$APK_TOOL
tar -xzf $APK_TOOL
./sbin/apk.static \
    -X $MIRROR/$VERSION/main \
    -U \
    --allow-untrusted \
    --root ././$ROOTFS_DIR \
    --initdb add alpine-base alpine-sdk sudo 

# Set Resolv.conf
echo "127.0.0.1 localhost" > $ROOTFS_DIR/etc/hosts
echo "nameserver 8.8.8.8" > $ROOTFS_DIR/etc/resolv.conf
echo "nameserver 8.8.4.4" >> $ROOTFS_DIR/etc/resolv.conf
echo "$MIRROR/$VERSION/main" >  $ROOTFS_DIR/etc/apk/repositories

# Cleaning up
rm -rf sbin
rm -f $ROOTFS_DIR/APK_TOOL

case "$1" in
    armhf) cp /usr/bin/qemu-arm-static $ROOTFS_DIR/usr/bin/
        ;;
    aarch64) cp /usr/bin/qemu-aarch64-static $ROOTFS_DIR/usr/bin/
        ;;
    *)  ;;
esac
echo "http://dl-cdn.alpinelinux.org/alpine/edge/community" >> $ROOTFS_DIR/etc/apk/repositories
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR apk update
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR apk add bash sudo dropbear mesa-gl x11vnc xterm twm expect

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

# Add Last Packages
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR apk add busybox
cp $ROOTFS_DIR/bin/busybox $ARCH_DIR/busybox
