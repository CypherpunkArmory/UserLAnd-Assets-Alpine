#! /bin/bash

export ARCH_DIR=output/${1}
export ROOTFS_DIR=$ARCH_DIR/rootfs

case "$1" in
    ) export ARCH_BOOTSTRAP_ARCH_OPT=armv7h
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

rm -rf $ARCH_DIR
mkdir -p $ARCH_DIR
rm -rf $ROOTFS_DIR
mkdir -p $ROOTFS_DIR

git clone https://github.com/tokland/arch-bootstrap.git $ARCH_DIR/arch-bootstrap
$ARCH_DIR/arch-bootstrap/arch-bootstrap.sh $ARCH_BOOTSTRAP_QEMU_OPT -a $ARCH_BOOTSTRAP_ARCH_OPT $ROOTFS_DIR

LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR pacman -S sudo dropbear tigervnc xterm xorg-twm expect --noconfirm

echo "127.0.0.1 localhost" > $ROOTFS_DIR/etc/hosts
echo "nameserver 8.8.8.8" > $ROOTFS_DIR/etc/resolv.conf
echo "nameserver 8.8.4.4" >> $ROOTFS_DIR/etc/resolv.conf

cp scripts/shrinkRootfs.sh $ROOTFS_DIR
chmod 777 $ROOTFS_DIR/shrinkRootfs.sh
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR ./shrinkRootfs.sh
rm $ROOTFS_DIR/shrinkRootfs.sh

tar --exclude='dev/*' --exclude='etc/mtab' -czvf $ARCH_DIR/rootfs.tar.gz -C $ROOTFS_DIR .

LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR pacman -S base-devel --noconfirm

#build disableselinux to go with this release
cp scripts/disableselinux.c $ROOTFS_DIR
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR gcc -shared -fpic disableselinux.c -o libdisableselinux.so
cp $ROOTFS_DIR/libdisableselinux.so $ARCH_DIR/libdisableselinux.so

#get busybox to go with the release
LC_ALL=C LANGUAGE=C LANG=C chroot $ROOTFS_DIR pacman -S busybox --noconfirm
cp $ROOTFS_DIR/bin/busybox $ARCH_DIR/busybox
