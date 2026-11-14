#!/bin/sh
set -eu

command -v pkg >/dev/null 2>&1 || {
  printf 'based: run this in Termux\n' >&2
  exit 1
}
: "${PREFIX:?run this in Termux}"
export TMPDIR="${TMPDIR:-$PREFIX/tmp}"

pkg update -y
pkg install -y bat clang coreutils curl fd fzf git make man ncurses-utils \
  neovim nodejs-lts openssh ripgrep tar zsh

BASED_BIN="${BASED_BIN:-$PREFIX/bin}"
BASED_DATA="${BASED_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/nvim}"
BASED_NVIM_CONFIG="${BASED_NVIM_CONFIG:-$HOME/.config/nvim}"
BASED_CONFIG="${BASED_CONFIG:-$HOME/.config/based}"
BASED_ZSHRC="${BASED_ZSHRC:-$HOME/.zshrc}"
export BASED_BIN BASED_DATA BASED_NVIM_CONFIG BASED_CONFIG BASED_ZSHRC

# shellcheck source=install/common.sh
. "$(dirname "$0")/common.sh"

install_zmx
install_dvtm
install_pi
install_fzf_lua
install_config
