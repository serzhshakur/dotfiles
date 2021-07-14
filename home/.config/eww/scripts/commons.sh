#!/bin/bash

export PATH=$HOME/.local/bin:$PATH

DIR=$(dirname "$0")
MONITOR=$(bspc query --names -M -m focused)
MONITORS=($(xrandr | grep -sw 'connected' | cut -d " " -f 1))
MONITOR_IDX=0

for i in "${!MONITORS[@]}"; do
  if [[ "${MONITORS[$i]}" == "$MONITOR" ]]; then
    MONITOR_IDX="${i}"
  fi
done

