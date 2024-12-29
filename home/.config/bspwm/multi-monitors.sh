#! /bin/sh

SOURCE_DIR=$(dirname "$0")
source $SOURCE_DIR/functions.sh

switch_to_monocle() {
  for desktop in "$@"; do
    if bspc query -D --names | grep -q "$desktop"; then
      bspc desktop "$desktop" -l monocle || true
    fi
  done
}

remove_desktops() {
  for desktop in "$@"; do
    if bspc query -D --names | grep -q "$desktop"; then
      bspc desktop "$desktop" -r || true
    fi
  done
}

MONITORS=$(get_monitors)
NUMBER_OF_MONITORS=$(echo -e "$MONITORS" | wc -l)

case $NUMBER_OF_MONITORS in
3)
  bspc monitor HDMI-1 -d s f 1 2
  bspc monitor DP-1 -d a d o 3
  bspc monitor eDP-1 -d u i
  ;;
2)
  for mon in $MONITORS; do
    case $mon in
    HDMI-* | DP-*)
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
  remove_desktops '1' '2' '3'
  ;;
esac

# switching certain desktops to monocle layout

switch_to_monocle a d f u i 1 2 3
