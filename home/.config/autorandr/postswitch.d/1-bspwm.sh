#!/bin/sh

# bspwm will create a marker file on system boot. If autorandr finds the file, it
# will remove it. This is to prevent double config reload on system boot.
MARKER_FILE=/tmp/bspwm

if [ -f $MARKER_FILE ]; then
  rm $MARKER_FILE
else
  BSPWM_CFG_DIR=$HOME/.config/bspwm

  $BSPWM_CFG_DIR/multi-monitors.sh || true
  $BSPWM_CFG_DIR/panel.sh || true
  $BSPWM_CFG_DIR/reapply_rules.sh || true

  notify-send -i display "autorandr" "Switched profile to \"$AUTORANDR_CURRENT_PROFILE\""
fi
