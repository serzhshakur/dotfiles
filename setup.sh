#!/bin/bash

function enable_services {
  for service in "$@"; do
    sudo systemctl enable --now $service
    sudo systemctl start $service
  done
}

function install_aur_pkg {
  pkg=$1
  if !(pacman -Q $pkg > /dev/null 2>&1)
  then
    git clone https://aur.archlinux.org/$pkg.git /tmp/packages/$pkg
    cd /tmp/packages/$pkg
    makepkg -si --noconfirm
    rm -rf /tmp/packages/$pkg
  fi
}

function install_pkg {
  sudo yay -S --needed --noconfirm $@
}

# Install yay
sudo pacman -S --needed --noconfirm git binutils make gcc fakeroot
install_aur_pkg yay

# Get faster mirrors
install_pkg reflector
sudo reflector -f 15 --save /etc/pacman.d/mirrorlist

# Installing necessary packages
install_pkg gvim alacritty \
            zsh oh-my-zsh-git \
	    xorg-{server,xinit,xinput,xwininfo,xlogo,xauth,xclock,twm} light \
	    mesa mesa-libgl \
	    xf86-video-vesa \
	    lightdm lightdm-gtk-greeter \
	    pulseaudio pulseaudio-alsa \
	    bluez bluez-utils pulseaudio-bluetooth blueman \
	    notification-daemon \
	    arc-gtk-theme flat-remix lxappearance \
	    flameshot \
	    rofi rofi-greenclip \
	    networkmanager network-manager-applet openvpn networkmanager-openvpn \
	    ttf-font-awesome ttf-fantasque-sans-mono ttf-jetbrains-mono noto-fonts \
	    qtile python-pip gcc pacman-contrib \
	    picom \
	    reflector \
	    docker \
	    jdk-openjdk openjdk-doc openjdk-src \
	    jetbrains-toolbox code \
	    postman \

# Some python libraries requred for qtile
sudo pip install psutil dateutil iwlib

# The very last step: removing orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

# Systemd
enable_services lightdm bluetooth docker

