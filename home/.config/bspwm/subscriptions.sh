#!/bin/bash

# Subscribing for node_add and node_remove in order to detect dialog windows.
# If a window considered being a dialog, disable focus_follows_pointer until the window is removed

# prevent multiple script instances
PID_FILE=/tmp/bspwm_subscriptions.pid
[[ -e $PID_FILE ]] && exit

echo $$ >"$PID_FILE"
trap "rm -f -- '$PID_FILE'" EXIT

######

WID_FILE=/tmp/bspwm_current_dialog

handle_node_add() {
  wid=$1
  if [ -n "$wid" ]; then

    # check if just created node is floating window
    if [[ -n $(bspc query -N -n "$wid.floating.window") ]]; then

      wtypes=$(xprop -id "$wid" _NET_WM_WINDOW_TYPE | awk -F' = ' '{print $2}')

      # check if just created window is dialog
      if [[ $wtypes == *"_NET_WM_WINDOW_TYPE_DIALOG"* ]]; then

        # disabling focus_follows_pointer while dialog is opened
        bspc config focus_follows_pointer false

        # focus the dialog
        bspc node -f "$wid"

        # saving window id in a file
        echo -n "$wid" >$WID_FILE
      fi
    fi
  fi
}

handle_node_remove() {
  wid=$1

  if [[ -n "$wid" ]]; then
    current_dialog_win_id=$(cat $WID_FILE)

    # check if just removed window stored in a file
    if [[ $wid == "$current_dialog_win_id" ]]; then
      # enabling back focus_follows_pointer
      bspc config focus_follows_pointer true
      echo "" >$WID_FILE
    fi
  fi
}

bspc subscribe node_add node_remove | while read -a msg; do
  event=${msg[0]} #  node_add | node_remove

  case $event in
  node_add)
    wid=${msg[4]}
    handle_node_add "$wid"
    ;;
  node_remove)
    wid=${msg[3]}
    handle_node_remove "$wid"
    ;;
  esac

done
