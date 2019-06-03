#!/bin/sh

#update our repos so we can install some packages
mkdir -p /var/cache/apk
ln -s /var/cache/apk /etc/apk/cache
apk update

#install some packages we need for UserLAnd
apk add bash sudo dropbear mesa-gl xvfb x11vnc xsetroot xterm twm expect shadow

#clean up after ourselves
apk cache clean
