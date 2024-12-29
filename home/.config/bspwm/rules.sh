#!/usr/bin/env bash

############ HELPERS ###########

to_desktop() {
  if [ "$#" -lt 2 ]; then
    echo "wrong number of args. Usage: to_desktop desktop_label wm_classes"
    return 1
  fi

  local DESKTOP=$1
  shift

  for wm_class in "$@"; do
    bspc rule -a "$wm_class" desktop="$DESKTOP"
  done
}

make_floating() {
  if [ "$#" -lt 1 ]; then
    echo "wrong number of args"
    return 1
  fi

  for wm_class in "$@"; do
    bspc rule -a "$wm_class" state=floating center=true
  done
}

###############################

to_desktop 'a' firefox
to_desktop 's' Alacritty
to_desktop 'd' jetbrains-idea code Code code-oss
to_desktop 'f' Pcmanfm
to_desktop 'o' KeePassXC
to_desktop 'i' Spotify
to_desktop 'u' Slack Ferdi Discord TelegramDesktop

make_floating \
  Lxappearance \
  Nitrogen \
  Blueman-manager \
  Qalculate-gtk \
  llpp \
  Viewinor \
  Nm-connection-editor \
  pavucontrol \
  jetbrains-toolbox \
  System-config-printer.py

# Getting rid of small annoying Slack window while having a call
bspc rule -a "*:*:Slack | mini panel" hidden=on
