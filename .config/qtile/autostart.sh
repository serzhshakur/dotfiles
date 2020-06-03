#!/bin/bash

# nm-applet to appear as a tray icon
nm-applet & 

# Blueman
blueman-applet & 

# 'lv' and 'ru' keyboard layouts, set keyboard shorcut to Shift+Alt
setxkbmap -layout lv,ru -variant ",phonetic_winkeys" -option "grp:lalt_lshift_toggle" & 

# Restore wallpaper
nitrogen --restore & 

# Starting a picom - compositor for Xorg
picom -b &

# Light locker
light-locker &

# PulseAudio System Tray
pasystray --notify=none &

# Battery tray icon
cbatticon &
