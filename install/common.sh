#!/bin/sh
set -eu

: "${BASED_BIN:?BASED_BIN is required}"
: "${BASED_DATA:?BASED_DATA is required}"
: "${BASED_NVIM_CONFIG:?BASED_NVIM_CONFIG is required}"

BASED_ROOT="${BASED_ROOT:-$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)}"
ZMX_VERSION=0.8.1
FZF_LUA_COMMIT=ded1c96d3d9d74634287d722431c26690968a4bf
ZMX_BASE="https://github.com/neurosnap/zmx/releases/download/v${ZMX_VERSION}"
FZF_LUA_URL="https://github.com/ibhagwan/fzf-lua/archive/${FZF_LUA_COMMIT}.tar.gz"

log() { printf 'based: %s\n' "$*"; }
die() { printf 'based: %s\n' "$*" >&2; exit 1; }

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

install_zmx() {
  case "$(uname -s)" in
    Darwin) os=macos ;;
    Linux) os=linux ;;
    *) die "unsupported OS: $(uname -s)" ;;
  esac
  case "$(uname -m)" in
    x86_64|amd64) arch=x86_64 ;;
    arm64|aarch64) arch=aarch64 ;;
    *) die "unsupported architecture: $(uname -m)" ;;
  esac
  asset="zmx-${ZMX_VERSION}-${os}-${arch}.tar.gz"
  tmp=$(mktemp -d)
  curl -fsSL -o "$tmp/$asset" "$ZMX_BASE/$asset"
  curl -fsSL -o "$tmp/$asset.sha256" "$ZMX_BASE/$asset.sha256"
  expected=$(cut -d' ' -f1 "$tmp/$asset.sha256")
  [ "$(sha256 "$tmp/$asset")" = "$expected" ] || die "checksum mismatch: $asset"
  tar xzf "$tmp/$asset" -C "$tmp"
  mkdir -p "$BASED_BIN"
  cp "$tmp/zmx" "$BASED_BIN/zmx"
  chmod 0755 "$BASED_BIN/zmx"
  rm -rf "$tmp"
  log "zmx $ZMX_VERSION -> $BASED_BIN/zmx"
}

install_fzf_lua() {
  dest="$BASED_DATA/fzf-lua"
  tmp=$(mktemp)
  curl -fsSL -o "$tmp" "$FZF_LUA_URL"
  rm -rf "$dest"
  mkdir -p "$dest"
  tar xzf "$tmp" -C "$dest" --strip-components=1
  rm -f "$tmp"
  log "fzf-lua $FZF_LUA_COMMIT -> $dest"
}

install_config() {
  mkdir -p "$BASED_NVIM_CONFIG" "$BASED_BIN"
  if [ -f "$BASED_NVIM_CONFIG/init.lua" ] &&
    ! cmp -s "$BASED_ROOT/.devcontainer/init.lua" "$BASED_NVIM_CONFIG/init.lua"; then
    cp "$BASED_NVIM_CONFIG/init.lua" "$BASED_NVIM_CONFIG/init.lua.based-backup"
  fi
  cp "$BASED_ROOT/.devcontainer/init.lua" "$BASED_NVIM_CONFIG/init.lua"
  cp "$BASED_ROOT/.devcontainer/j" "$BASED_BIN/j"
  chmod 0755 "$BASED_BIN/j"
  if [ -n "${BASED_BASHRC:-}" ]; then
    cp "$BASED_ROOT/.devcontainer/bashrc" "$BASED_BASHRC"
  fi
  log "j and nvim config installed"
}
