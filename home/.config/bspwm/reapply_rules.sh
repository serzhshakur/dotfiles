#!/bin/bash

for wid in $(bspc query -N -n .window); do
  bspc node -f "$wid"
  xdo hide "$wid" && xdo show "$wid"
done
