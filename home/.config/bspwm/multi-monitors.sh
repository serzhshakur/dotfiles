#! /bin/sh

switch_to_monocle() {
  for desktop in "$@"; do
    if bspc query -D --names | grep -q "$desktop"; then
      bspc desktop "$desktop" -l monocle
    fi
  done
}

monitors=$(xrandr | grep -sw 'connected' | cut -d " " -f 1)
number_of_monitors=$(xrandr | grep -sw 'connected' | cut -d " " -f 1 | wc -l)

case $number_of_monitors in
3)
  bspc monitor HDMI-1 -d s f 1 2
  bspc monitor DP-1 -d a d o 3
  bspc monitor eDP-1 -d u i
  ;;
2)
  for mon in $monitors; do
    case $mon in
    HDMI-1 | HDMI-2 | DP-1)
      bspc monitor "$mon" -d a s d f 1 2 3
      ;;
    eDP-1)
      bspc monitor "$mon" -d u i o
      ;;
    esac
  done
  ;;
*)
  bspc monitor -d a s d f u i o
  ;;
esac

# switching certain desktops to monocle layout

switch_to_monocle a d f u i 1 2 3

# restarting Polybar panel

~/.config/bspwm/panel.sh
