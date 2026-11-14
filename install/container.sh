#!/bin/sh
set -eu

[ "$(id -u)" -eq 0 ] || {
  printf 'based: run this as root in the image build\n' >&2
  exit 1
}

BASED_HOME="${BASED_HOME:-/home/vscode}"
BASED_BIN=/usr/local/bin
BASED_DATA="$BASED_HOME/.local/share/nvim"
BASED_NVIM_CONFIG="$BASED_HOME/.config/nvim"
BASED_CONFIG="$BASED_HOME/.config/based"
BASED_ZSHRC="$BASED_HOME/.zshrc"
export BASED_BIN BASED_DATA BASED_NVIM_CONFIG BASED_CONFIG BASED_ZSHRC

# shellcheck source=install/common.sh
. "$(dirname "$0")/common.sh"

apt-get update
apt-get install -y --no-install-recommends \
  bat build-essential ca-certificates curl fd-find fzf git libncurses-dev \
  man-db openssh-client ripgrep tar zsh
rm -rf /var/lib/apt/lists/*
ln -sf /usr/bin/batcat /usr/local/bin/bat
ln -sf /usr/bin/fdfind /usr/local/bin/fd

mkdir -p /usr/local/share/fzf
curl -fsSL -o /usr/local/share/fzf/key-bindings.zsh \
  "https://raw.githubusercontent.com/junegunn/fzf/$(fzf --version | cut -d' ' -f1)/shell/key-bindings.zsh"

install_zmx
install_dvtm
install_nvim
install_pi
install_fzf_lua
install_config

chsh -s /bin/zsh vscode 2>/dev/null || true
chown -R vscode:vscode "$BASED_HOME/.config" "$BASED_HOME/.local" "$BASED_HOME/.zshrc"
