# based

Composable terminal workspace built around `zsh`, `nvim`, and `pi`. Everything is driven by single-letter commands in `bin/` that read and write plain text lines so they compose with `fzf` and Unix pipes across local and remote machines:

- **Android (Termux)** and **Linux / Container**: `zmx` for persistent sessions and `dvtm` for pane tiling.
- **macOS**: `rex` for sessions and `rift` for window tiling.

## Primitives

| Command | Action |
|---|---|
| `a` | `pi` coding agent (`a [args...]`) |
| `d` | SSH devices (`d [host [-- cmd...]]`; no arguments lists, `d -- [cmd...]` reads host from stdin) |
| `e` | `nvim` editor (`e [files...]`) |
| `f` | find files (`fd --hidden --follow --exclude .git`) |
| `g` | `git` (`g [args...]`) |
| `h` | manual pages (`man [args...]`) |
| `j` | fuzzy jump to session or workspace (`j [target]`) |
| `k` | keybind legend and config (`k [list [tool] \| edit [tool] \| delete [tool key]]`; reads stdin) |
| `l` | list directory (`ls -lahF`) |
| `m` | session multiplexer (`m [target \| detach \| delete [target...]]`; no arguments lists, `m attach` reads target from stdin) |
| `s` | search file contents (`rg --hidden --smart-case --glob !.git`) |
| `w` | list workspace paths (`~`, `~/Notes`, `~/Workspaces/<ctx>[/<proj>]`) |

## Composition

```sh
w | fzf | m attach                  # pick workspace and attach session
m | fzf | m attach                  # switch active session
m | fzf -m | m delete               # delete selected sessions
d | fzf | d --                      # pick SSH host and connect
d host -- w \| fzf \| m attach      # attach workspace session on remote host
k | fzf | k delete                  # delete keybind entry from legend
f | fzf | xargs e                   # find file and open in nvim
```

## Keybinds

Bindings follow consistent patterns across `zsh`, `nvim`, `pi`, `dvtm`, and `rex` (plus `rift` on macOS):

- **Leader**: `C-/` across `nvim`, `pi`, and `dvtm` (`Cmd` in `rex`, `CAG` / `Hyper` in `rift`).
- **One-letter actions**: `f` files, `s` search, `b` buffers, `o` oldfiles, `w` word or workspaces, `j` jump session, `d` detach or device, `e` editor, `a` agent.
- **Navigation and layout**: `h/j/k/l` directional focus, move, and resize; `i/o` prev/next workspace; `n/N` next/prev window or match; `Space` cycle layout or open Rex; `Enter` zoom pane to master.

Full reference in [config/keybinds.tsv](config/keybinds.tsv) (or run `k list [tool]`).

## Install

```sh
./install/macos.sh      # macOS: nvim, pi, rift, primitives, and configs
./install/termux.sh     # Android (Termux): zmx, dvtm, pi, primitives, and configs
./run                   # Container: pull ghcr.io/lilfeelz/based:latest (or ./run build) and enter zsh
./test/run              # Run shellcheck, shfmt, and unit tests (--install for full binary install test)
```
