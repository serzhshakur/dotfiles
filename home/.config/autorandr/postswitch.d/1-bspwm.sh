#!/bin/sh

BSPWM_CFG_DIR=$HOME/.config/bspwm

$BSPWM_CFG_DIR/multi-monitors.sh || true
$BSPWM_CFG_DIR/panel.sh || true
$BSPWM_CFG_DIR/reapply_rules.sh || true

notify-send -i display "autorandr" "Switched profile to \"$AUTORANDR_CURRENT_PROFILE\""
