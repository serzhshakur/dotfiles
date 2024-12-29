#! /bin/sh

get_monitors() {
  if command autorandr >/dev/null; then
    autorandr --config | rg --multiline --invert-match 'output.*\noff' | rg 'output (.*)' -or '$1'
  elif command xrandr >/dev/null; then
    xrandr | rg '(.*) connected ' -or '$1'
  else
    echo 'eDP-1'
  fi
}
