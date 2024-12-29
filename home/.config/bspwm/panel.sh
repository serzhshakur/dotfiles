#!/usr/bin/env bash

SOURCE_DIR=$(dirname "$0")
source $SOURCE_DIR/functions.sh

# Killing running polybar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

for m in $(get_monitors); do
  echo $m
  MONITOR=$m polybar --reload bspwm-bar 2>/tmp/polybar &
done
