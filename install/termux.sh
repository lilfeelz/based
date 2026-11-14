#!/bin/sh
set -eu

command -v pkg >/dev/null 2>&1 || {
  printf 'based: run this in Termux\n' >&2
  exit 1
}
: "${PREFIX:?run this in Termux}"
export TMPDIR="${TMPDIR:-$PREFIX/tmp}"

pkg update -y
pkg install -y bat clang coreutils curl fd fzf git jq make man ncurses-utils \
  neovim nodejs-lts openssh ripgrep tar zsh

BASED_BIN="${BASED_BIN:-$PREFIX/bin}"
BASED_ZSHRC="${BASED_ZSHRC:-$HOME/.zshrc}"
export BASED_BIN BASED_ZSHRC

sh "$(dirname "$0")/common.sh" zmx dvtm pi config
