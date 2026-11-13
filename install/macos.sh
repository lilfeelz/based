#!/bin/sh
set -eu

command -v brew >/dev/null 2>&1 || {
  printf 'based: Homebrew is required\n' >&2
  exit 1
}

brew install bat fd fzf neovim ripgrep

BASED_BIN="${BASED_BIN:-$HOME/.local/bin}"
BASED_DATA="${BASED_DATA:-${XDG_DATA_HOME:-$HOME/.local/share}/nvim}"
BASED_NVIM_CONFIG="${BASED_NVIM_CONFIG:-$HOME/.config/nvim}"

. "$(dirname "$0")/common.sh"

install_zmx
install_fzf_lua
install_config

case ":$PATH:" in
  *":$BASED_BIN:"*) ;;
  *) printf 'based: add %s to PATH for j and zmx\n' "$BASED_BIN" ;;
esac
