#!/bin/bash

set -eu -o pipefail

SCRIPT_DIR=$(realpath "$(dirname $0)")
source $SCRIPT_DIR/functions.sh

LOCAL_BIN=~/.local/bin
mkdir -p $LOCAL_BIN

trap failure ERR

sudo apt update && sudo apt -y upgrade

################### ZSH ###################

install_pkg zsh

if ! echo $SHELL | grep -q zsh; then
  chsh -s $(which zsh)
fi

# OMZ
if [ ! -d $HOME/.oh-my-zsh ]; then
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
    | sh -s -- --keep-zshrc --unattended
fi

################## Links #####################

for f in .zshrc .zshenv .p10k.zsh .vimrc; do
  ln -sf $SCRIPT_DIR/$f $HOME/$f
done

############### Install other ################

install_pkg neovim zsh tmux htop bat exa tree jq direnv
ln -sf /usr/bin/batcat $LOCAL_BIN/bat

# Rust
which rustc || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
  | sh -s -- -y --no-modify-path

# zoxide
sh -c "$(curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh)"

# FZF
clone_or_pull https://github.com/junegunn/fzf.git $HOME/.fzf
$HOME/.fzf/install --all

# # Powerlevel 10k
P10K_DEST=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
clone_or_pull https://github.com/romkatv/powerlevel10k.git $P10K_DEST

# # ZSH syntax highlighting
clone_or_pull https://github.com/zdharma-continuum/fast-syntax-highlighting ~/.fast-syntax-highlighting

#################### SNAPS ######################

sudo snap install google-cloud-cli --classic

################### Node JS #####################

NVM_TAG=$(curl https://api.github.com/repos/nvm-sh/nvm/tags | jq -r '.[0].name')
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_TAG/install.sh | bash
. $HOME/.nvm/nvm.sh
nvm install node # "node" is an alias for the latest version
npm install --global yarn

echo "Node JS version:" $(node -v)
echo "NPM verson:" $(npm -v)

##################### TMUX ######################

mkdir -p ~/.config/tmux
mkdir -p ~/.tmux/plugins
ln -sf $SCRIPT_DIR/tmux.conf ~/.config/tmux/tmux.conf
clone_or_pull https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

################## Cleanup ######################

sudo apt autoremove && sudo apt clean

################### Misc ########################

cp -n $SCRIPT_DIR/.gitconfig ~/.gitconfig
# This file is meant to store secrets
touch $HOME/.zshenv_private

success
