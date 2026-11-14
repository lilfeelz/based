#!/bin/sh
set -eu

BASED_ROOT="${BASED_ROOT:-$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)}"
BASED_HOME="${BASED_HOME:-$HOME}"
BASED_BIN="${BASED_BIN:-${PREFIX:+$PREFIX/bin}}"
BASED_BIN="${BASED_BIN:-$BASED_HOME/.local/bin}"
BASED_DATA="${BASED_DATA:-${XDG_DATA_HOME:-$BASED_HOME/.local/share}/nvim}"
BASED_NVIM_CONFIG="${BASED_NVIM_CONFIG:-${XDG_CONFIG_HOME:-$BASED_HOME/.config}/nvim}"
BASED_CONFIG="${BASED_CONFIG:-${XDG_CONFIG_HOME:-$BASED_HOME/.config}/based}"
BASED_PINS="${BASED_PINS:-$BASED_ROOT/install/pins.json}"

log() { printf 'based: %s\n' "$*"; }
die() { printf 'based: %s\n' "$*" >&2; exit 1; }

pin() {
  jq -er "$1" "$BASED_PINS" || die "missing pin: $1"
}

platform() {
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=$(uname -m | sed 's/^amd64$/x86_64/;s/^arm64$/aarch64/')
  printf '%s-%s\n' "$os" "$arch"
}

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

fetch() {
  url="$1"
  expected="$2"
  out="$3"
  curl -fsSL -o "$out" "$url"
  actual=$(sha256 "$out")
  [ "$actual" = "$expected" ] || die "checksum mismatch for $url: expected $expected, got $actual"
}

install_zmx() {
  plat=$(platform)
  ver=$(pin '.zmx.version')
  asset=$(pin ".zmx[\"$plat\"].asset")
  sha=$(pin ".zmx[\"$plat\"].sha256")
  tmp=$(mktemp -d)
  fetch "https://github.com/neurosnap/zmx/releases/download/v${ver}/${asset}" "$sha" "$tmp/$asset"
  tar xzf "$tmp/$asset" -C "$tmp"
  mkdir -p "$BASED_BIN"
  cp "$tmp/zmx" "$BASED_BIN/zmx"
  chmod 0755 "$BASED_BIN/zmx"
  rm -rf "$tmp"
  log "zmx $ver -> $BASED_BIN/zmx"
}

install_dvtm() {
  commit=$(pin '.dvtm.commit')
  sha=$(pin '.dvtm.sha256')
  tmp=$(mktemp -d)
  fetch "https://github.com/martanne/dvtm/archive/${commit}.tar.gz" "$sha" "$tmp/dvtm.tar.gz"
  tar xzf "$tmp/dvtm.tar.gz" -C "$tmp" --strip-components=1
  make -C "$tmp" PREFIX="$(dirname "$BASED_BIN")" dvtm dvtm-editor
  mkdir -p "$BASED_BIN"
  for b in dvtm dvtm-status dvtm-editor dvtm-pager; do
    cp -f "$tmp/$b" "$BASED_BIN/$b"
    chmod 0755 "$BASED_BIN/$b"
  done
  rm -rf "$tmp"
  log "dvtm $commit -> $BASED_BIN/dvtm"
}

install_nvim() {
  plat=$(platform)
  ver=$(pin '.nvim.version')
  asset=$(pin ".nvim[\"$plat\"].asset")
  sha=$(pin ".nvim[\"$plat\"].sha256")
  dest="$BASED_DATA/nvim-dist"
  tmp=$(mktemp)
  fetch "https://github.com/neovim/neovim/releases/download/v${ver}/${asset}" "$sha" "$tmp"
  rm -rf "$dest"
  mkdir -p "$dest" "$BASED_BIN"
  tar xzf "$tmp" -C "$dest" --strip-components=1
  rm -f "$tmp"
  ln -sf "$dest/bin/nvim" "$BASED_BIN/nvim"
  log "nvim $ver -> $BASED_BIN/nvim"
}

install_pi() {
  ver=$(pin '.pi.version')
  dest="$BASED_DATA/pi"
  mkdir -p "$BASED_BIN"
  if [ -n "${TERMUX_VERSION:-}" ]; then
    sha=$(pin '.pi.npm.sha256')
    tmp=$(mktemp)
    fetch "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${ver}.tgz" "$sha" "$tmp"
    npm install -g --prefix "$(dirname "$BASED_BIN")" "$tmp"
    rm -f "$tmp"
    log "pi $ver (npm) -> $BASED_BIN/pi"
    return
  fi
  plat=$(platform)
  asset=$(pin ".pi[\"$plat\"].asset")
  sha=$(pin ".pi[\"$plat\"].sha256")
  tmp=$(mktemp)
  fetch "https://github.com/earendil-works/pi/releases/download/v${ver}/${asset}" "$sha" "$tmp"
  rm -rf "$dest"
  mkdir -p "$dest"
  tar xzf "$tmp" -C "$dest" --strip-components=1
  rm -f "$tmp"
  chmod 0755 "$dest/pi"
  ln -sf "$dest/pi" "$BASED_BIN/pi"
  log "pi $ver -> $BASED_BIN/pi"
}

install_rift() {
  [ "$(uname -s)" = Darwin ] || return 0
  ver=$(pin '.rift.version')
  sha=$(pin '.rift.sha256')
  tmp=$(mktemp -d)
  fetch "https://github.com/acsandmann/rift/releases/download/v${ver}/rift-universal-macos-${ver}.tar.gz" "$sha" "$tmp/rift.tar.gz"
  tar xzf "$tmp/rift.tar.gz" -C "$tmp"
  mkdir -p "$BASED_BIN"
  for b in rift rift-cli; do
    cp "$tmp/$b" "$BASED_BIN/$b"
    chmod 0755 "$BASED_BIN/$b"
  done
  rm -rf "$tmp"
  log "rift $ver -> $BASED_BIN/rift"
}

install_fzf_lua() {
  commit=$(pin '."fzf-lua".commit')
  sha=$(pin '."fzf-lua".sha256')
  dest="$BASED_DATA/fzf-lua"
  tmp=$(mktemp)
  fetch "https://github.com/ibhagwan/fzf-lua/archive/${commit}.tar.gz" "$sha" "$tmp"
  rm -rf "$dest"
  mkdir -p "$dest"
  tar xzf "$tmp" -C "$dest" --strip-components=1
  rm -f "$tmp"
  log "fzf-lua $commit -> $dest"
}

install_config() {
  mkdir -p "$BASED_NVIM_CONFIG" "$BASED_CONFIG" "$BASED_BIN"
  if [ -f "$BASED_NVIM_CONFIG/init.lua" ] &&
    ! cmp -s "$BASED_ROOT/config/init.lua" "$BASED_NVIM_CONFIG/init.lua"; then
    cp "$BASED_NVIM_CONFIG/init.lua" "$BASED_NVIM_CONFIG/init.lua.based-backup"
  fi
  cp "$BASED_ROOT/config/init.lua" "$BASED_NVIM_CONFIG/init.lua"
  for c in "$BASED_ROOT"/config/*; do
    [ "${c##*/}" = init.lua ] && continue
    cp "$c" "$BASED_CONFIG/${c##*/}"
  done
  for b in "$BASED_ROOT"/bin/*; do
    name="${b##*/}"
    cp "$b" "$BASED_BIN/$name"
    chmod 0755 "$BASED_BIN/$name"
  done
  ln -sf "$BASED_BIN/m" "$BASED_BIN/j"
  if [ -n "${BASED_ZSHRC:-}" ]; then
    cp "$BASED_ROOT/config/zshrc" "$BASED_ZSHRC"
  fi
  log "primitives and configs installed"
}
