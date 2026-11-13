#!/bin/sh
set -eu

command -v pkg >/dev/null 2>&1 || {
  printf 'based: run this in Termux\n' >&2
  exit 1
}
: "${PREFIX:?run this in Termux}"

pkg update -y
pkg install -y bat coreutils curl dvtm fd fzf git neovim ripgrep tar

BASED_BIN="${BASED_BIN:-$PREFIX/bin}"
BASED_DATA="${BASED_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/nvim}"
BASED_NVIM_CONFIG="${BASED_NVIM_CONFIG:-$HOME/.config/nvim}"

. "$(dirname "$0")/common.sh"

install_zmx
install_fzf_lua
install_config
