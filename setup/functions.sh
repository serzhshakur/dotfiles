#!/bin/bash

function enable_services() {
  for service in "$@"; do
    echo ""
    echo "------------------------------------"
    echo "enabling service $service"
    sudo systemctl enable "$service"
    sudo systemctl start "$service"
    echo "------------------------------------"
  done
}

function add_user_to_groups() {
  for group in "$@"; do
    echo ""
    echo "------------------------------------"
    echo "adding user to group $group"
    if grep -q "$group" /etc/group && ! groups "${USER}" | grep -qw "$group"; then
      sudo usermod -aG "${group}" "${USER}"
    fi
    echo "------------------------------------"
  done
}

function enable_user_services() {
  for service in "$@"; do
    echo ""
    echo "------------------------------------"
    echo "enabling user service $service"
    sudo systemctl --user enable "$service"
    sudo systemctl --user start "$service"
    echo "------------------------------------"
  done
}

function install_aur_pkg() {
  pkg=$1
  if ! (pacman -Q "$pkg" >/dev/null 2>&1); then
    git clone https://aur.archlinux.org/"$pkg".git /tmp/packages/"$pkg"
    cd /tmp/packages/"$pkg" || exit
    makepkg -si --noconfirm
    rm -rf /tmp/packages/"$pkg"
  fi
}

# Update mirrors
function rank_and_update_mirrors() {
  curl -s "https://archlinux.org/mirrorlist/?country=CZ&country=LT&country=RU&country=NL&country=BY&country=DE&country=FR&country=GB&protocol=https&use_mirror_status=on" |
    sed -e 's/^#Server/Server/' -e '/^#/d' |
    rankmirrors -n 25 - >/tmp/mirrorlist

  sudo mv /tmp/mirrorlist /etc/pacman.d/mirrorlist
  sudo pacman -Syyuu
}

function install_vscode_extensions() {
  declare -a extensions=(
    "arcticicestudio.nord-visual-studio-code"
    "bradlc.vscode-tailwindcss"
    "csstools.postcss"
    "dbaeumer.vscode-eslint"
    "EditorConfig.EditorConfig"
    "humao.rest-client"
    "JScearcy.rust-doc-viewer"
    "k--kato.intellij-idea-keybindings"
    "lorenzopirro.rust-flash-snippets"
    "matklad.rust-analyzer"
    "ms-vscode.test-adapter-converter"
    "robertrossmann.remedy"
    "serayuzgur.crates"
    "tamasfe.even-better-toml"
    "vadimcn.vscode-lldb"
    "ZhangYue.rust-mod-generator"
  )
  for e in "${extensions[@]}"; do
    code --install-extension "$e"
  done
}
