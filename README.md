# based

Composable terminal workspace built around `zsh`, `nvim`, and `pi`. Everything is driven by single-letter commands in `bin/` that read and write plain text lines so they compose with `fzf` and Unix pipes across local and remote machines:

- **Android (Termux)** and **Linux / Container**: `zmx` for persistent sessions and `dvtm` for pane tiling.
- **macOS**: `rex` for sessions and `rift` for window tiling.

## Primitives

| Command | Action |
|---|---|
| `a` | `pi` coding agent (`a [args...]`) |
| `d` | SSH devices (`d [list \| host [cmd...]]`; reads host from stdin) |
| `e` | `nvim` editor (`e [files...]`) |
| `f` | find files (`fd --hidden --follow --exclude .git`) |
| `g` | `git` (`g [args...]`) |
| `h` | manual pages (`man [args...]`) |
| `j` | fuzzy jump to session or workspace (`j [target]`) |
| `k` | keybind legend and config (`k [list [tool] \| edit [tool] \| delete [tool key]]`; reads stdin) |
| `l` | list directory (`ls -lahF`) |
| `m` | session multiplexer (`m [list \| attach [target] \| detach \| delete [target...]]`; reads stdin) |
| `s` | search file contents (`rg --hidden --smart-case --glob !.git`) |
| `w` | list workspace paths (`~`, `~/Notes`, `~/Workspaces/<ctx>[/<proj>]`) |

## Composition

```sh
w | fzf | m                  # pick workspace and attach session
m list | fzf | m             # switch active session
m list | fzf -m | m delete   # delete selected sessions
d list | fzf | d             # pick SSH host and connect
d host 'w | fzf | m'         # attach workspace session on remote host
k list | fzf | k delete      # delete keybind entry from legend
f | fzf | xargs e            # find file and open in nvim
```

## Keybinds

| Tool | Key | Action |
|---|---|---|
| `dvtm` | `Ctrl+A ?` | dvtm help |
| `dvtm` | `Ctrl+A Enter` | zoom pane to master |
| `dvtm` | `Ctrl+A Space` | cycle layout |
| `dvtm` | `Ctrl+A c` | new shell pane |
| `dvtm` | `Ctrl+A h/l` | resize master area |
| `dvtm` | `Ctrl+A j/k` | next/prev pane |
| `dvtm` | `Ctrl+A q` | quit all panes |
| `dvtm` | `Ctrl+A x` | close pane |
| `nvim` | `<Space>d` | mux detach session |
| `nvim` | `<Space>fb` | fzf buffers |
| `nvim` | `<Space>ff` | fzf files |
| `nvim` | `<Space>fg` | fzf live grep |
| `nvim` | `<Space>fr` | fzf recent files |
| `nvim` | `<Space>fw` | fzf grep word |
| `nvim` | `<Space>j` | mux switch session |
| `pi` | `Ctrl+O` | edit prompt in nvim |
| `pi` | `Ctrl+X` | leader menu |
| `pi` | `Esc` | vim normal mode |
| `rex` | `Cmd+F` | file picker |
| `rex` | `Cmd+G` | workspace picker |
| `rex` | `Cmd+S` | search picker |
| `rift` | `CAG+H` | focus window left |
| `rift` | `CAG+I` | prev workspace |
| `rift` | `CAG+J` | focus window down |
| `rift` | `CAG+K` | focus window up |
| `rift` | `CAG+L` | focus window right |
| `rift` | `CAG+N` | focus next window |
| `rift` | `CAG+O` | next workspace |
| `rift` | `CAG+Space` | open Rex |
| `rift` | `Hyper+H` | move window left |
| `rift` | `Hyper+J` | move window down |
| `rift` | `Hyper+K` | move window up |
| `rift` | `Hyper+L` | move window right |
| `rift` | `Hyper+N` | focus prev window |
| `zsh` | `Alt+C` | fzf cd directory |
| `zsh` | `Ctrl+R` | fzf command history |
| `zsh` | `Ctrl+T` | fzf paste file path |
| `zsh` | `a` | pi |
| `zsh` | `d` | ssh host list/connect |
| `zsh` | `e` | nvim |
| `zsh` | `f` | fd --hidden --follow --exclude .git |
| `zsh` | `g` | git |
| `zsh` | `h` | man |
| `zsh` | `j` | fuzzy jump workspace or session |
| `zsh` | `k` | keybinds (list/edit/delete) |
| `zsh` | `l` | ls -lahF |
| `zsh` | `m` | session mux (list/attach/detach/delete) |
| `zsh` | `s` | rg --hidden --smart-case --glob !.git |
| `zsh` | `w` | workspace directory list |

## Install

```sh
./install/macos.sh      # macOS: nvim, pi, rift, primitives, and configs
./install/termux.sh     # Android (Termux): zmx, dvtm, pi, primitives, and configs
./run                   # Container: pull ghcr.io/lilfeelz/based:latest (or ./run build) and enter zsh
./test/run              # Run shellcheck, shfmt, and unit tests (--install for full binary install test)
```
