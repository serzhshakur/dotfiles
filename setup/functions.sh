#!/bin/bash

function enable_services {
  for service in "$@"; do
    sudo systemctl enable --now $service
    sudo systemctl start $service
  done
}

function enable_user_services {
  for service in "$@"; do
    sudo systemctl --user enable --now $service
    sudo systemctl --user start $service
  done
}

function install_aur_pkg { 
  pkg=$1
  if !(pacman -Q $pkg > /dev/null 2>&1)
  then
    git clone https://aur.archlinux.org/$pkg.git /tmp/packages/$pkg
    cd /tmp/packages/$pkg
    sudo makepkg -si --noconfirm
    rm -rf /tmp/packages/$pkg
  fi
}

function install_pkg {
  yay -S \
      --needed \
      --noconfirm \
      --removemake \
      --nodiffmenu \
      --nocleanmenu \
      --noeditmenu  \
      $@
  # removing orphans
  yay -Rns $(yay -Qtdq) &> /dev/null
}

