# based

Composable dev environment PoC across scales and contexts, built around `zsh`, `nvim`, and `pi` with direct `curl` + pinned-commit builds:

- **Android (Termux)** and **Container (`ghcr.io/lilfeelz/based`)**: `zmx` + `dvtm` for local and SSH session persistence and tiling.
- **macOS**: `rex` + `rift` for local and remote sessions and window tiling.

## Primitives

Single-letter tools designed to be piped together:

| Command | Action |
|---|---|
| `w` | print workspace paths (`~`, `~/Notes`, `~/Workspaces/<ctx>[/<proj>]`) |
| `m` | session mux (`m list`, `m attach [target]`, `m detach`, `m delete [target]`; reads stdin) |
| `j` | jump (`{ m list; w; } \| fzf \| m attach`) |
| `d` | SSH devices/hosts (`d list`, `d [host] [cmd...]`; reads stdin) |
| `k` | custom keybinds (`k list [tool]`, `k edit [tool]`, `k delete [tool key]`; reads stdin) |
| `f` | find files and dirs (`fd --hidden --follow --exclude .git`) |
| `s` | search text (`rg --hidden --smart-case --glob '!.git'`) |
| `l` | list directory (`ls -lahF`) |
| `g` | `git` |
| `h` | `man` |
| `e` | `nvim` |
| `a` | `pi` |

## Pipes

```sh
w | fzf | m                  # pick workspace, attach session
m list | fzf | m             # switch active session
m list | fzf -m | m delete   # delete selected sessions
d list | fzf | d             # pick SSH host and connect
d host 'w | fzf | m'         # attach workspace session on remote host
k list | fzf | k delete      # remove a custom keybind
f | fzf | xargs e            # find file and open in nvim
```

## Install

All core components (`zmx`, `dvtm`, `nvim`, `pi`, `fzf-lua`, `rift`) are fetched directly via `curl` with pinned commits/releases and SHA256 verification in `install/pins.sh`.

```sh
./install/termux.sh     # Termux: zmx, dvtm (built from source), nvim, pi, fzf-lua
./install/macos.sh      # macOS: nvim, pi, rift, fzf-lua, rex link
./run                   # Container: pull ghcr.io/lilfeelz/based:latest (or ./run build) and enter zsh
```
