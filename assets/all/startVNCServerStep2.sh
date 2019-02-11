#! /bin/bash

if [[ -z "${INITIAL_USERNAME}" ]]; then
  INITIAL_USERNAME="user"
fi

if [[ -z "${INITIAL_VNC_PASSWORD}" ]]; then
  INITIAL_VNC_PASSWORD="userland"
fi

if [ ! -f /home/$INITIAL_USERNAME/.vnc/passwd ]; then
mkdir /home/$INITIAL_USERNAME/.vnc 
x11vnc -storepasswd $INITIAL_VNC_PASSWORD /home/$INITIAL_USERNAME/.vnc/passwd
fi

rm /tmp/.X51-lock
Xvfb :51 -screen 0 800x640x24 &
sleep 1
export DISPLAY=:51
LANG=C twm &
x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :51 -N -usepw -shared -noshm &
VNC_PID=$!
echo $VNC_PID > /home/$INITIAL_USERNAME/.vnc/localhost:51.pid

cd ~
DISPLAY=localhost:51 xterm -geometry 80x24+0+0 -e /bin/bash --login &
