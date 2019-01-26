#! /bin/bash

MIRROR=http://dl-5.alpinelinux.org/alpine
ARCH=x86_64
CHROOT=alpine-chroot-newest
VERSION=latest-stable
APK_TOOL=apk-tools-static-2.10.1-r0.apk

# Root has $UID 0
ROOT_UID=0
if [ "$UID" != "$ROOT_UID" ]
then
    echo "You are not root. Please use su to become root."
    exit 0
fi

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
