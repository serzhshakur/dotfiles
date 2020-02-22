#!/bin/bash

# yay -S flat-remix rofi-greenclip
# pacman -S network-manager network-manager-applet blueman nitrogen pacman-contrib lxappearance pcmanfm-gtk3 python-pip gcc ttf-font-awesome picom

# Enable touchpad tapping
xinput set-prop 11 "libinput Tapping Enabled" 1 &
# nm-applet to appear as a tray icon
nm-applet & 
# Blueman
blueman-applet & 
# 'lv' and 'ru' keyboar layouts, change via Shift+Alt
setxkbmap -layout lv,ru -variant ",phonetic_winkeys" -option "grp:lalt_lshift_toggle" & 
# Restore wallpaper
nitrogen --restore & 
# Starting greenclip daemon
greenclip daemon &
# Starting a picom - compositor for Xorg
picom -b &

