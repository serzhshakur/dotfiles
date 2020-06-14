#!/bin/bash

function enable_services() {
  for service in "$@"; do
    sudo systemctl enable --now "$service"
    sudo systemctl start "$service"
  done
}

function add_user_to_groups() {
  for group in "$@"; do
    if grep -q $group /etc/group && ! groups ${USER} | grep -qw $group; then
      sudo usermod -aG ${group} ${USER}
    fi
  done
}

function enable_user_services() {
  for service in "$@"; do
    sudo systemctl --user enable --now "$service"
    sudo systemctl --user start "$service"
  done
}

function install_aur_pkg() {
  pkg=$1
  if ! (pacman -Q $pkg >/dev/null 2>&1); then
    git clone https://aur.archlinux.org/$pkg.git /tmp/packages/$pkg
    cd /tmp/packages/$pkg
    sudo makepkg -si --noconfirm
    rm -rf /tmp/packages/$pkg
  fi
}

# Update mirrors
function rank_and_update_mirrors() {
  curl -s "https://www.archlinux.org/mirrorlist/?country=CZ&country=LT&country=RU&country=NL&country=BY&country=DE&country=FR&country=GB&protocol=https&use_mirror_status=on" |
    sed -e 's/^#Server/Server/' -e '/^#/d' |
    rankmirrors -n 25 - >/tmp/mirrorlist

  sudo mv /tmp/mirrorlist /etc/pacman.d/mirrorlist
  sudo pacman -Syyuu --ignore=qtile
}
