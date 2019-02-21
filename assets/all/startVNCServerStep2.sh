#! /bin/bash

if [[ -z "${INITIAL_USERNAME}" ]]; then
  INITIAL_USERNAME="user"
fi

if [[ -z "${INITIAL_VNC_PASSWORD}" ]]; then
  INITIAL_VNC_PASSWORD="userland"
fi

export LD_LIBRARY_PATH=

if [ ! -f /home/$INITIAL_USERNAME/.vnc/passwd ]; then
mkdir /home/$INITIAL_USERNAME/.vnc 
x11vnc -storepasswd $INITIAL_VNC_PASSWORD /home/$INITIAL_USERNAME/.vnc/passwd
fi

if [[ -z "${DIMENSIONS}" ]]; then
	DIMENSIONS="1024x768"
fi

if [ ! -f /home/$INITIAL_USERNAME/.vncrc ]; then
	vncrc_line="\$geometry = \"${DIMENSIONS}\";"
	echo $vncrc_line > /home/$INITIAL_USERNAME/.vncrc
fi

rm /tmp/.X51-lock
Xvfb :51 -screen 0 1024x768x16 &
sleep 2
export DISPLAY=:51
cd ~
xrdb -load $HOME/.Xresources
xsetroot -solid gray &
xterm -geometry 80x24+0+0 -e /bin/bash --login &
LANG=C twm &
x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :51 -N -usepw -shared -noshm &
VNC_PID=$!
echo $VNC_PID > /home/$INITIAL_USERNAME/.vnc/localhost:51.pid
