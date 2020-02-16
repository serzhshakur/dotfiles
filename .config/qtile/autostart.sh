#!/bin/bash

# yay -S flat-remix rofi-greenclip
# pacman -S nm-applet blueman nitrogen pacman-contrib lxappearance pcmanfm-gtk3 python-pip gcc ttf-font-awesome 

xinput set-prop 11 "libinput Tapping Enabled" 1 &
nm-applet &  
blueman-applet & 
setxkbmap -layout lv,ru -variant ",phonetic_winkeys" -option "grp:lalt_lshift_toggle" & # change layout via Shift+Alt
nitrogen --restore & 
greenclip daemon &

