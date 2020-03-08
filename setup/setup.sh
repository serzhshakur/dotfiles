#!/bin/bash

source ./functions.sh

user=`whoami`

# Timezone 
timedatectl set-ntp true
timedatectl set-timezone Europe/Riga

# Locale
locale-gen en_GB.UTF-8
echo LANG=en_GB.UTF-8 > /etc/locale.conf
export LANG=en_GB.UTF-8
source /etc/profile.d/locale.sh

# Setup faster mirrors
install_pkg reflector
sudo reflector -f 15 --save /etc/pacman.d/mirrorlist

# Installing yay
install_pkg git binutils make gcc fakeroot
install_aur_pkg yay

# Installing necessary packages
install_pkg gvim alacritty \
	    xorg-{server,xinit,xinput,xwininfo,xlogo,xauth,xclock,twm} light \
	    mesa mesa-libgl \
	    xf86-video-vesa \
            zsh oh-my-zsh-git \
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
	    docker \
	    jdk-openjdk openjdk-doc openjdk-src \
	    jetbrains-toolbox code \
	    postman \
	    rambox-bin \ 

# Some python libraries requred for qtile
sudo pip install -U --upgrade-strategy=only-if-needed psutil python-dateutil

# The very last step: removing orphaned packages
sudo pacman -Rns $(pacman -Qtdq)

# Systemd
enable_services lightdm bluetooth docker picom

# Adding user to necessary groups
sudo usermod -aG docker $user

# Move config files
cp $PWD/../.config/* ~/.config/

# Setup desktop notifications
sudo cp ./org.freedesktop.Notifications.service /usr/share/dbus-1/services/org.freedesktop.Notifications.service

