#!/bin/bash

rm /setup.sh

echo "127.0.0.1 localhost" > /etc/hosts
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 8.8.4.4" >> /etc/resolv.conf

echo "#!/bin/sh" > /etc/profile.d/userland.sh
echo "unset LD_PRELOAD" >> /etc/profile.d/userland.sh
echo "unset LD_LIBRARY_PATH" >> /etc/profile.d/userland.sh
echo "export LIBGL_ALWAYS_SOFTWARE=1" >> /etc/profile.d/userland.sh
chmod +x /etc/profile.d/userland.sh

echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/main" >> /etc/apk/repositories
echo "http://dl-cdn.alpinelinux.org/alpine/latest-stable/community" >> /etc/apk/repositories

#tar up what we have before we grow it
tar -czvf /output/rootfs.tar.gz --exclude sys --exclude dev --exclude proc --exclude mnt --exclude etc/mtab --exclude output --exclude input --exclude .dockerenv /

#build disableselinux to go with this release
apk update
apk add alpine-sdk
gcc -shared -fpic /input/disableselinux.c -o /output/libdisableselinux.so

#grab a static version of busybox that we can use to set things up later
apk add busybox-static
cp /bin/busybox.static output/busybox
