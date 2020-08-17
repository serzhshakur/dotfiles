#!/bin/bash

theme="power.rasi"
chosen=$(echo -e "  Lock\n  Shutdown\n  Reboot" | rofi -dmenu -theme $theme -lines 3 -i)
confirm_message="Are you sure?"
confirm_options="  Yes\n  No"

# https://www.freedesktop.org/software/systemd/man/systemd-sleep.conf.html#Description
if [[ $chosen == *"Lock" ]]; then
  light-locker-command -l
elif [[ $chosen == *"Shutdown" ]]; then
  confirm=$(echo -e "$confirm_options" | rofi -dmenu -theme $theme -mesg "$confirm_message" -lines 2 -i)
  if [[ $confirm == *"Yes" ]]; then
    systemctl poweroff
  fi
elif [[ $chosen == *"Reboot" ]]; then
  confirm=$(echo -e "$confirm_options" | rofi -dmenu -theme $theme -mesg "$confirm_message" -lines 2 -i)
  if [[ $confirm == *"Yes" ]]; then
    systemctl reboot
  fi
fi
