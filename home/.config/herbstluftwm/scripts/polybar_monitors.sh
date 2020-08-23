#!/usr/bin/env bash

hc() {
  herbstclient "$@"
}
monitors_count="$(hc attr monitors.count)"
active_icon="%{T4}%{F#eaa560}%{F-}"
inactive_icon="%{T4}%{F#969595}%{F-}"
offset="%{O10}"
two_mon_setup=("$active_icon$offset$inactive_icon" "$inactive_icon$offset$active_icon")
three_mon_setup=("$active_icon$offset$inactive_icon$offset$inactive_icon" "$inactive_icon$offset$active_icon$offset$inactive_icon" "$inactive_icon$offset$inactive_icon$offset$active_icon")

if [[ $monitors_count -gt 1 ]]; then
  focused_monitor="$(hc attr monitors.focus.index)"
  hc -i 'tag_changed' |
    while read -r _ _ mon; do
      if [[ $mon -ne $focused_monitor ]]; then
        focused_monitor=$mon
        case $monitors_count in
        2)
          echo "${two_mon_setup[focused_monitor]}"
          ;;
        3)
          echo "${three_mon_setup[focused_monitor]}"
          ;;
        esac
      fi
    done
fi
