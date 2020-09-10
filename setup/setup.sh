#!/bin/bash
set -e

source ./functions.sh

USER=$(whoami)

# Installing some packages for makepkg to work
sudo pacman -S --needed git binutils make gcc fakeroot patch # consider installing just 'base-devel' package

# Installing yay
install_aur_pkg yay

function install_pkg() {
  yay -S \
    --needed \
    --noconfirm \
    --removemake \
    --nodiffmenu \
    --nocleanmenu \
    --noeditmenu \
    $@
  # removing orphans
  #yay -Rns $(yay -Qtdq) &> /dev/null
}

# Timezone
sudo timedatectl set-ntp true
sudo timedatectl set-timezone Europe/Riga

# Locale
sudo locale-gen en_GB.UTF-8
echo LANG=en_GB.UTF-8 | sudo tee /etc/locale.conf
export LANG=en_GB.UTF-8
sudo /bin/bash /etc/profile.d/locale.sh

# Setup faster mirrors
rank_and_update_mirrors

# Installing necessary packages
install_pkg gvim alacritty \
  xorg-{server,xinit,xinput,xwininfo,xlogo,xauth,xclock,twm,xrdb} \
  arandr autorandr \
  udisks2 udiskie \
  lightdm lightdm-gtk-greeter light-locker \
  xkblayout-state light \
  mesa mesa-libgl \
  xf86-video-vesa \
  networkmanager network-manager-applet openvpn networkmanager-openvpn \
  zsh oh-my-zsh-git \
  htop bat exa fzf tree \
  dmenu rofi rofi-greenclip \
  dunst \
  picom redshift \
  syncthing keepassxc
# Audio
install_pkg pulseaudio pulseaudio-alsa pavucontrol pasystray \
  bluez bluez-utils pulseaudio-bluetooth blueman playerctl
# Themes, fonts etc.
install_pkg noto-fonts nerd-fonts-noto-sans-mono \
  ttf-droid ttf-hack ttf-font-awesome ttf-jetbrains-mono ttf-iosevka \
  arc-gtk-theme flat-remix lxappearance qt5ct qt5-styleplugins nitrogen \
  fontpreview-git
# Printing
install_pkg cups cups-pdf cups-pk-helper system-config-printer
# Some GUI tools
install_pkg llpp viewnior \
  cbatticon \
  gsimplecal \
  pcmanfm-gtk3 file-roller \
  flameshot \
  joplin-appimg \
  qalculate-gtk libreoffice-still
# WMs
## - Qtile
install_pkg qtile-git python-pip gcc pacman-contrib
## - Herbstlufwm
install_pkg herbstluftwm-git
# Internet
install_pkg firefox vivaldi chromium transmission-gtk
# Communication
install_pkg rambox-bin slack-desktop
# Entertainment
install_pkg spotify vlc
# Development etc.
install_pkg jdk-openjdk openjdk-doc openjdk-src \
  jetbrains-toolbox code \
  postgresql-libs \
  nodejs npm \
  go \
  docker docker-compose kubectl kubectx \
  postman-bin

# Some python libraries requred for qtile
sudo pip install -U --upgrade-strategy=only-if-needed psutil python-dateutil

# Move config files
cp -r $PWD/../.config/* ~/.config/

# Systemd
enable_services lightdm NetworkManager bluetooth docker
enable_user_services greenclip redshift-gtk mpris-proxy

# Syncthing
sudo systemctl enable syncthing@$USER.service
sudo systemctl start syncthing@$USER.service

# Adding user to necessary groups
add_user_to_groups docker video storage

# Wallpaper
sudo mkdir -p /usr/share/pictures
sudo cp -r ./nature.jpg /usr/share/pictures/

# Xorg settings
sudo cp ./system/etc/X11/xorg.conf.d/* /etc/X11/xorg.conf.d/

# Lightdm settings
sudo cp ./system/etc/lightdm/* /etc/lightdm/

# Pollkit
sudo cp ./system/etc/polkit-1/rules.d/* /etc/polkit-1/rules.d/
sudo chmod 644 ./system/etc/polkit-1/rules.d/

# ZSH syntax highlighting
git clone https://github.com/zdharma/fast-syntax-highlighting.git \
  ~ZSH_CUSTOM/plugins/fast-syntax-highlighting

echo ""
echo "------------------------------------"
echo "System setup successfully completed!"
echo "------------------------------------"
