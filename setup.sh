#!/bin/bash

function install_yay {
  if !(pacman -Q yay > /dev/null 2>&1)
  then
    sudo pacman -S --needed --noconfirm binutils make gcc fakeroot
    git clone https://aur.archlinux.org/yay.git /tmp/packages/yay
    cd yay
    makepkg -si
  fi
}

