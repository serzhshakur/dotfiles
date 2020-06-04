#!/bin/bash
set -e

source ./functions.sh

user=$(whoami)

# Installing some packages for makepkg to work
sudo pacman -S --needed git binutils make gcc fakeroot patch

# Installing yay
install_aur_pkg yay

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
	    lightdm lightdm-gtk-greeter light-locker \
	    xkblayout-state light \
	    mesa mesa-libgl \
	    xf86-video-vesa \
	    networkmanager network-manager-applet openvpn networkmanager-openvpn \
	    cups cups-pdf cups-pk-helper system-config-printer \
      zsh oh-my-zsh-git \
	    qtile python-pip gcc pacman-contrib \
	    pulseaudio pulseaudio-alsa pavucontrol pasystray \
	    bluez bluez-utils pulseaudio-bluetooth blueman \
	    fzf tree pcmanfm-gtk3 file-roller \
	    notification-daemon \
	    arc-gtk-theme flat-remix lxappearance qt5ct qt5-styleplugins \
	    rofi rofi-greenclip \
	    llpp viewnior \
	    cbatticon \
	    ttf-font-awesome ttf-fantasque-sans-mono ttf-jetbrains-mono noto-fonts ttf-droid ttf-hack \
	    jdk-openjdk openjdk-doc openjdk-src \
	    go \
	    firefox vivaldi chromium \
	    syncthing keepassxc \
	    picom redshift flameshot joplin-appimg \
	    docker docker-compose kubectl kubectx \
	    jetbrains-toolbox code \
	    postman \
	    rambox-bin slack-desktop \
	    spotify vlc \
	    transmission-gtk \
	    qalculate-gtk libreoffice-still gnome-font-viewer \

# Some python libraries requred for qtile
sudo pip install -U --upgrade-strategy=only-if-needed psutil python-dateutil

# Systemd
enable_services lightdm NetworkManager bluetooth docker
enable_user_services greenclip redshift-gtk

# Syncthing
sudo systemctl enable syncthing@$user.service
sudo systemctl start syncthing@$user.service

# Adding user to necessary groups
sudo usermod -aG docker $user
sudo usermod -aG video $user

# Wallpaper
sudo mkdir -p /usr/share/pictures
sudo cp -r ./nature.jpg /usr/share/pictures/

# Move config files
cp -r $PWD/../.config/* ~/.config/

# Setup desktop notifications
sudo cp ./org.freedesktop.Notifications.service /usr/share/dbus-1/services/org.freedesktop.Notifications.service

# Xorg settings
sudo cp ./system/xorg/99-libinput-custom-config.conf /etc/X11/xorg.conf.d/99-libinput-custom-config.conf

# Lightdm settings
sudo cp ./system/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf

# ZSH syntax highlighting 
git clone https://github.com/zdharma/fast-syntax-highlighting.git \
  ~ZSH_CUSTOM/plugins/fast-syntax-highlighting


echo ""
echo "------------------------------------"
echo "System setup successfully completed!"
echo "------------------------------------"
