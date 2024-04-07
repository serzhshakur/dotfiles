#!/bin/bash

set -eu -o pipefail

#################################################
################# FUNCTIONS #####################
#################################################

install_pkg() {
  sudo apt install -y $@
}

clone_or_pull() {
  local URL="${1:?no url provided}"
  local DEST="${2:?no dest path provided}"
  if git -C $DEST status; then
    git -C $DEST reset --hard
    git -C $DEST pull --depth 1
  else
    rm -rf $DEST || true
    git clone --depth=1 $URL $DEST
  fi
}

RED='\033[0;31m'
GREEN='\033[0;32m'
RESET='\033[0m'

green() {
  echo -e "${GREEN}$@${RESET}"
}

red() {
  echo -e "${RED}$@${RESET}"
}

# Hooks

failure() {
  local error_code=$?
  local error_line=$BASH_LINENO
  local error_command=$BASH_COMMAND
  red "---------------------------------------"
  red "Error occurred on line $error_line: $error_command (exit code: $error_code)"
}

success() {
  green "---------------------------------------"
  green "Successfully completed!"
}
