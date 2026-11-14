#!/bin/sh
set -eu

command -v brew >/dev/null 2>&1 || {
  printf 'based: Homebrew is required\n' >&2
  exit 1
}

brew install bat fd fzf jq ripgrep

sh "$(dirname "$0")/common.sh" nvim pi rift config
