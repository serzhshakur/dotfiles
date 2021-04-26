#! /bin/sh

number_of_monitors=$(xrandr | grep -sw 'connected' | cut -d " " -f 1 | wc -l)

if [ $number_of_monitors -eq 3 ]; then
  bspc monitor HDMI-1 -d s f 1 2
  bspc monitor DP-1 -d a d o 3
  bspc monitor eDP-1 -d u i
elif [ $number_of_monitors -eq 2 ]; then
  bspc monitor HDMI-1 -d a s d f 1 2 3
  bspc monitor eDP-1 -d u i o
else
  bspc monitor -d a s d f u i o
fi
