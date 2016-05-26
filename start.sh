#!/usr/bin/env sh
sleep 10
xset s off
xset -dpms
xset s noblank
matchbox-window-manager & 
bash /home/pi/two_way_mirror/application.linux-armv6hf/two_way_mirror
