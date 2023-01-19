#!/bin/bash
set -e

source ./functions.sh

USER=sergey
ensure_user_exists $USER

# Install sudo if necessary
if ! which sudo &>/dev/null; then
  pacman -S sudo
  sudo usermod -aG wheel $USER
  echo "$USER ALL=(ALL) ALL" >/etc/sudoers.d/1-custom
  exit 1
fi

# Installing some packages for makepkg to work
sudo pacman -S --needed git binutils make gcc fakeroot patch # consider installing just 'base-devel' package

# Install Rust
which rustc || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Installing yay
install_aur_pkg paru

function install_pkg() {
  paru -S \
    --noconfirm \
    --removemake \
    --cleanafter \
    $@
  # removing orphans
  #paru -Rns $(paru -Qtdq) &> /dev/null
}

# Setup faster mirrors
#rank_and_update_mirrors

# Installing necessary packages
install_pkg gvim alacritty \
  xorg-{server,xinit,xinput,xwininfo,xlogo,xauth,xclock,twm,xrdb,mkfontscale,xfontsel,xlsfonts} \
  arandr autorandr \
  udisks2 udiskie \
  lightdm lightdm-gtk-greeter \
  xss-lock slock \
  xkblayout-state light \
  mesa mesa-libgl \
  xf86-video-vesa \
  networkmanager network-manager-applet openvpn networkmanager-openvpn \
  zsh oh-my-zsh-git \
  htop bat exa lf-bin fzf tree jq \
  man-db tealdeer \
  ncdu \
  dmenu rofi rofi-greenclip \
  dunst \
  picom redshift \
  syncthing keepassxc \
  pacman-contrib \
  reflector

# Audio
install_pkg pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
  pavucontrol playerctl \
  bluez blueman

# Themes, fonts etc.
install_pkg noto-fonts noto-fonts-emoji \
  ibm-fonts ttf-font-awesome ttf-iosevka \
  arc-gtk-theme papirus-icon-theme lxappearance qt5ct qt5-styleplugins nitrogen \
  fontpreview-git
# Printing
install_pkg cups cups-pdf cups-pk-helper system-config-printer
# Some GUI tools
install_pkg viewnior \
  cbatticon \
  gsimplecal \
  pcmanfm-gtk3 file-roller ranger \
  flameshot \
  joplin-appimage \
  qalculate-gtk libreoffice-still
## WM
install_pkg bspwm sxhkd xdo polybar
# Internet
install_pkg firefox chromium transmission-gtk
# Entertainment
install_pkg vlc spotify
# Development etc.
install_pkg code aur/code-marketplace \
  postgresql-libs \
  nodejs npm \
  docker kubectl kubectx \
  postman-bin

# Move config files
mkdir -p ~/.config && cp -r $PWD/../home/.config/* ~/.config/

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
enable_user_services greenclip.service redshift-gtk pipewire pipewire-pulse wireplumber

# Syncthing
sudo systemctl enable syncthing@$USER.service
sudo systemctl start syncthing@$USER.service

# Enable time synchronization
sudo systemctl enable systemd-timesyncd.service

# Enable Scheduled fstrim (only makes sense for SSDs)
sudo systemctl enable fstrim.timer

# Enable Scheduled Mirrorlist Updates
sudo systemctl enable reflector.timer

# ZSH syntax highlighting
git clone https://github.com/zdharma/fast-syntax-highlighting.git \
  ~ZSH_CUSTOM/plugins/fast-syntax-highlighting

echo ""
echo "------------------------------------"
echo "System setup successfully completed!"
echo "------------------------------------"
