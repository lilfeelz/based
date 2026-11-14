#!/bin/sh
set -eu

: "${BASED_BIN:?BASED_BIN is required}"
: "${BASED_DATA:?BASED_DATA is required}"
: "${BASED_NVIM_CONFIG:?BASED_NVIM_CONFIG is required}"

BASED_ROOT="${BASED_ROOT:-$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)}"
BASED_CONFIG="${BASED_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/based}"

# shellcheck source=install/pins.sh
. "$BASED_ROOT/install/pins.sh"

log() { printf 'based: %s\n' "$*"; }
die() { printf 'based: %s\n' "$*" >&2; exit 1; }

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
  case "$(uname -s):$(uname -m)" in
    Linux:x86_64|Linux:amd64)
      asset="zmx-${ZMX_VERSION}-linux-x86_64.tar.gz"
      sha="$ZMX_SHA_LINUX_X86_64" ;;
    Linux:arm64|Linux:aarch64)
      asset="zmx-${ZMX_VERSION}-linux-aarch64.tar.gz"
      sha="$ZMX_SHA_LINUX_AARCH64" ;;
    Darwin:arm64|Darwin:aarch64)
      asset="zmx-${ZMX_VERSION}-macos-aarch64.tar.gz"
      sha="$ZMX_SHA_MACOS_AARCH64" ;;
    Darwin:x86_64|Darwin:amd64)
      asset="zmx-${ZMX_VERSION}-macos-x86_64.tar.gz"
      sha="$ZMX_SHA_MACOS_X86_64" ;;
    *) die "unsupported platform for zmx: $(uname -s) $(uname -m)" ;;
  esac
  tmp=$(mktemp -d)
  fetch "https://github.com/neurosnap/zmx/releases/download/v${ZMX_VERSION}/${asset}" "$sha" "$tmp/$asset"
  tar xzf "$tmp/$asset" -C "$tmp"
  mkdir -p "$BASED_BIN"
  cp "$tmp/zmx" "$BASED_BIN/zmx"
  chmod 0755 "$BASED_BIN/zmx"
  rm -rf "$tmp"
  log "zmx $ZMX_VERSION -> $BASED_BIN/zmx"
}

install_dvtm() {
  tmp=$(mktemp -d)
  fetch "https://github.com/martanne/dvtm/archive/${DVTM_COMMIT}.tar.gz" "$DVTM_SHA" "$tmp/dvtm.tar.gz"
  tar xzf "$tmp/dvtm.tar.gz" -C "$tmp" --strip-components=1
  make -C "$tmp" PREFIX="$(dirname "$BASED_BIN")" dvtm dvtm-editor
  mkdir -p "$BASED_BIN"
  for b in dvtm dvtm-status dvtm-editor dvtm-pager; do
    cp -f "$tmp/$b" "$BASED_BIN/$b"
    chmod 0755 "$BASED_BIN/$b"
  done
  rm -rf "$tmp"
  log "dvtm $DVTM_COMMIT -> $BASED_BIN/dvtm"
}

install_nvim() {
  case "$(uname -s):$(uname -m)" in
    Linux:x86_64|Linux:amd64)
      asset="nvim-linux-x86_64.tar.gz"
      sha="$NVIM_SHA_LINUX_X86_64" ;;
    Linux:arm64|Linux:aarch64)
      asset="nvim-linux-arm64.tar.gz"
      sha="$NVIM_SHA_LINUX_ARM64" ;;
    Darwin:arm64|Darwin:aarch64)
      asset="nvim-macos-arm64.tar.gz"
      sha="$NVIM_SHA_MACOS_ARM64" ;;
    Darwin:x86_64|Darwin:amd64)
      asset="nvim-macos-x86_64.tar.gz"
      sha="$NVIM_SHA_MACOS_X86_64" ;;
    *) die "unsupported platform for nvim: $(uname -s) $(uname -m)" ;;
  esac
  dest="$BASED_DATA/nvim-dist"
  tmp=$(mktemp)
  fetch "https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${asset}" "$sha" "$tmp"
  rm -rf "$dest"
  mkdir -p "$dest" "$BASED_BIN"
  tar xzf "$tmp" -C "$dest" --strip-components=1
  rm -f "$tmp"
  ln -sf "$dest/bin/nvim" "$BASED_BIN/nvim"
  log "nvim $NVIM_VERSION -> $BASED_BIN/nvim"
}

install_pi() {
  dest="$BASED_DATA/pi"
  mkdir -p "$BASED_BIN"
  if [ -n "${TERMUX_VERSION:-}" ]; then
    tmp=$(mktemp)
    fetch "https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-${PI_VERSION}.tgz" "$PI_NPM_TGZ_SHA" "$tmp"
    npm install -g --prefix "$(dirname "$BASED_BIN")" "$tmp"
    rm -f "$tmp"
    log "pi $PI_VERSION (npm) -> $BASED_BIN/pi"
    return
  fi
  case "$(uname -s):$(uname -m)" in
    Linux:x86_64|Linux:amd64)
      asset="pi-linux-x64.tar.gz"
      sha="$PI_SHA_LINUX_X64" ;;
    Linux:arm64|Linux:aarch64)
      asset="pi-linux-arm64.tar.gz"
      sha="$PI_SHA_LINUX_ARM64" ;;
    Darwin:arm64|Darwin:aarch64)
      asset="pi-darwin-arm64.tar.gz"
      sha="$PI_SHA_DARWIN_ARM64" ;;
    Darwin:x86_64|Darwin:amd64)
      asset="pi-darwin-x64.tar.gz"
      sha="$PI_SHA_DARWIN_X64" ;;
    *) die "unsupported platform for pi: $(uname -s) $(uname -m)" ;;
  esac
  tmp=$(mktemp)
  fetch "https://github.com/earendil-works/pi/releases/download/v${PI_VERSION}/${asset}" "$sha" "$tmp"
  rm -rf "$dest"
  mkdir -p "$dest"
  tar xzf "$tmp" -C "$dest" --strip-components=1
  rm -f "$tmp"
  chmod 0755 "$dest/pi"
  ln -sf "$dest/pi" "$BASED_BIN/pi"
  log "pi $PI_VERSION -> $BASED_BIN/pi"
}

install_rift() {
  [ "$(uname -s)" = Darwin ] || return 0
  tmp=$(mktemp -d)
  fetch "https://github.com/acsandmann/rift/releases/download/v${RIFT_VERSION}/rift-universal-macos-${RIFT_VERSION}.tar.gz" "$RIFT_SHA_MACOS" "$tmp/rift.tar.gz"
  tar xzf "$tmp/rift.tar.gz" -C "$tmp"
  mkdir -p "$BASED_BIN"
  for b in rift rift-cli; do
    cp "$tmp/$b" "$BASED_BIN/$b"
    chmod 0755 "$BASED_BIN/$b"
  done
  rm -rf "$tmp"
  log "rift $RIFT_VERSION -> $BASED_BIN/rift"
}

install_fzf_lua() {
  dest="$BASED_DATA/fzf-lua"
  tmp=$(mktemp)
  fetch "https://github.com/ibhagwan/fzf-lua/archive/${FZF_LUA_COMMIT}.tar.gz" "$FZF_LUA_SHA" "$tmp"
  rm -rf "$dest"
  mkdir -p "$dest"
  tar xzf "$tmp" -C "$dest" --strip-components=1
  rm -f "$tmp"
  log "fzf-lua $FZF_LUA_COMMIT -> $dest"
}

install_config() {
  mkdir -p "$BASED_NVIM_CONFIG" "$BASED_CONFIG" "$BASED_BIN"
  if [ -f "$BASED_NVIM_CONFIG/init.lua" ] &&
    ! cmp -s "$BASED_ROOT/config/init.lua" "$BASED_NVIM_CONFIG/init.lua"; then
    cp "$BASED_NVIM_CONFIG/init.lua" "$BASED_NVIM_CONFIG/init.lua.based-backup"
  fi
  cp "$BASED_ROOT/config/init.lua" "$BASED_NVIM_CONFIG/init.lua"
  cp "$BASED_ROOT/config/zshrc" "$BASED_CONFIG/zshrc"
  cp "$BASED_ROOT/config/keybinds.tsv" "$BASED_CONFIG/keybinds.tsv"
  cp "$BASED_ROOT/config/rift.toml" "$BASED_CONFIG/rift.toml"
  for b in w m d k; do
    cp "$BASED_ROOT/bin/$b" "$BASED_BIN/$b"
    chmod 0755 "$BASED_BIN/$b"
  done
  ln -sf "$BASED_BIN/m" "$BASED_BIN/j"
  if [ -n "${BASED_ZSHRC:-}" ]; then
    cp "$BASED_ROOT/config/zshrc" "$BASED_ZSHRC"
  fi
  log "primitives (w, m, d, k) and configs installed"
}
