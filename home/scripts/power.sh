#!/bin/bash

theme="power.rasi"
chosen=$(echo -e "  Lock\n  Suspend\n  Shutdown\n  Reboot" | rofi -dmenu -theme $theme -i)
confirm_message="Are you sure?"
confirm_options="  Yes\n  No"

# https://www.freedesktop.org/software/systemd/man/systemd-sleep.conf.html#Description
if [[ $chosen == *"Lock" ]]; then
  bslock
elif [[ $chosen == *"Shutdown" ]]; then
  confirm=$(echo -e "$confirm_options" | rofi -dmenu -theme $theme -mesg "$confirm_message" -i)
  if [[ $confirm == *"Yes" ]]; then
    systemctl poweroff
  fi
elif [[ $chosen == *"Reboot" ]]; then
  confirm=$(echo -e "$confirm_options" | rofi -dmenu -theme $theme -mesg "$confirm_message" -i)
  if [[ $confirm == *"Yes" ]]; then
    systemctl reboot
  fi
elif [[ $chosen == *"Suspend" ]]; then
  confirm=$(echo -e "$confirm_options" | rofi -dmenu -theme $theme -mesg "$confirm_message" -i)
  if [[ $confirm == *"Yes" ]]; then
    systemctl suspend
  fi
fi
