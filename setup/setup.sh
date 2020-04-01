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
	    xorg-{server,xinit,xinput,xwininfo,xlogo,xauth,xclock,twm,xrdb}
	    xkblayout-state light \
	    mesa mesa-libgl \
	    xf86-video-vesa \
            zsh oh-my-zsh-git \
	    lightdm lightdm-gtk-greeter light-locker \
	    qtile python-pip gcc pacman-contrib \
	    pulseaudio pulseaudio-alsa pavucontrol pasystray \
	    bluez bluez-utils pulseaudio-bluetooth blueman \
	    notification-daemon \
	    arc-gtk-theme flat-remix lxappearance \
	    rofi rofi-greenclip \
	    llpp \ # pdf viewer
	    viewnior \ # image viewer
	    flameshot \ #screenshot taking app
	    networkmanager network-manager-applet openvpn networkmanager-openvpn \
	    ttf-font-awesome ttf-fantasque-sans-mono ttf-jetbrains-mono noto-fonts ttf-droid \
	    picom \
	    docker \
	    jdk-openjdk openjdk-doc openjdk-src \
	    jetbrains-toolbox code \
	    postman \
	    rambox-bin \ 
	    spotify \
	    transmission-gtk \
	    qalculate-gtk libreoffice-still \

# Some python libraries requred for qtile
sudo pip install -U --upgrade-strategy=only-if-needed psutil python-dateutil

# Systemd
enable_services lightdm bluetooth docker picom
enable_user_services greenclip

# Adding user to necessary groups
sudo usermod -aG docker $user

# Wallpaper
cp ./nature.jpg /usr/share/pictures/

# Move config files
cp $PWD/../.config/* ~/.config/

# Setup desktop notifications
sudo cp ./org.freedesktop.Notifications.service /usr/share/dbus-1/services/org.freedesktop.Notifications.service

# Xorg settings
sudo cp ./setup/system/xorg/99-libinput-custom-config.conf /etc/X11/xorg.conf.d/99-libinput-custom-config.conf

# Lightdm settings
sudo cp ./system/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

