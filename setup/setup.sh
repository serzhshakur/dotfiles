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

# Setup faster mirrors
#rank_and_update_mirrors

# Installing necessary packages
install_pkg gvim alacritty \
  xorg-{server,xinit,xinput,xwininfo,xlogo,xauth,xclock,twm,xrdb,mkfontscale,xfontsel,xlsfonts} \
  arandr autorandr \
  udisks2 udiskie \
  lightdm lightdm-gtk-greeter \
  xss-lock bslock \
  xkblayout-state light \
  mesa mesa-libgl \
  xf86-video-vesa \
  networkmanager network-manager-applet openvpn networkmanager-openvpn \
  zsh oh-my-zsh-git \
  htop bat exa lf fzf tree jq \
  ncdu \ `# disk usage analyzer`
  etcher-bin \ `# Flash drive writer`
  dmenu rofi rofi-greenclip \
  dunst \
  picom redshift \
  syncthing keepassxc
# Audio
install_pkg pulseaudio pulseaudio-alsa pavucontrol pasystray \
  bluez bluez-utils pulseaudio-bluetooth blueman playerctl
# Themes, fonts etc.
install_pkg noto-fonts noto-fonts-emoji nerd-fonts-noto-sans-mono \
  ttf-droid ttf-hack ttf-font-awesome ttf-jetbrains-mono ttf-iosevka \
  arc-gtk-theme papirus-icon-theme lxappearance qt5ct qt5-styleplugins nitrogen \
  fontpreview-git
# Printing
install_pkg cups cups-pdf cups-pk-helper system-config-printer
# Some GUI tools
install_pkg llpp viewnior \
  cbatticon \
  gsimplecal \
  pcmanfm-gtk3 file-roller ranger \ `# file managers`
  flameshot \
  joplin-appimage \
  qalculate-gtk libreoffice-still
# WM
install_pkg bspwm sxhkd polybar
# Internet
install_pkg firefox chromium transmission-gtk
# Communication
install_pkg rambox-bin slack-desktop
# Entertainment
install_pkg vlc spotify
# Development etc.
install_pkg jdk-openjdk openjdk-doc openjdk-src \
  jetbrains-toolbox code \
  postgresql-libs \
  nodejs npm \
  go \
  docker docker-compose kubectl kubectx \
  postman-bin

# Move config files
#cp -r $PWD/../.config/* ~/.config/

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

# Systemd
enable_services lightdm NetworkManager bluetooth docker
enable_user_services greenclip.service redshift-gtk mpris-proxy

# Syncthing
sudo systemctl enable syncthing@$USER.service
sudo systemctl start syncthing@$USER.service

# ZSH syntax highlighting
git clone https://github.com/zdharma/fast-syntax-highlighting.git \
  ~ZSH_CUSTOM/plugins/fast-syntax-highlighting

echo ""
echo "------------------------------------"
echo "System setup successfully completed!"
echo "------------------------------------"
