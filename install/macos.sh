#!/bin/sh
set -eu

command -v brew >/dev/null 2>&1 || {
  printf 'based: Homebrew is required\n' >&2
  exit 1
}

brew install bat fd fzf jq ripgrep

# shellcheck source=install/common.sh
. "$(dirname "$0")/common.sh"

install_nvim
install_pi
install_rift
install_fzf_lua
install_config

if [ -x /Applications/Rex.app/Contents/Resources/bin/rex ] && [ ! -e "$BASED_BIN/rex" ]; then
  ln -sf /Applications/Rex.app/Contents/Resources/bin/rex "$BASED_BIN/rex"
fi

case ":$PATH:" in
  *":$BASED_BIN:"*) ;;
  *) printf 'based: add %s to PATH\n' "$BASED_BIN" ;;
esac
