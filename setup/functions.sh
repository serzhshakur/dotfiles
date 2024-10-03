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

function ensure_user_exists() {
  USER=$1
  if [[ -z $USER ]]; then
    echo "requires a user name"
    exit 1
  fi
  # Check if user is set up
  if ! id -u "$USER" &>/dev/null; then
    echo "setup a user '$USER' first"
    echo "-------------------------"
    echo "> useradd -m $USER"
    echo "> passwd $USER"
    echo "-------------------------"
    exit 1
  fi
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

reinstall_gcloud() {
    local BIN_DIR="$HOME/.local/bin"
    mkdir -p $BIN_DIR
    rm -rf $BIN_DIR/google-cloud-sdk || true
    
    curl \
    https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz \
    -o /tmp/google-cloud-cli-linux-x86_64.tar.gz
    
    tar -xf /tmp/google-cloud-cli-linux-x86_64.tar.gz -C $BIN_DIR
    
    $BIN_DIR/google-cloud-sdk/install.sh \
      --usage-reporting=false \
      --command-completion=true \
      --install-python=false \
      --path-update=true \
      --quiet
}