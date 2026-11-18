# based

Composable terminal workspace for macOS, Linux and Termux, built around `zsh`, `nvim` and `pi`. Single-letter commands in `bin/` read and write plain text lines so they compose with `fzf` and Unix pipes across local and remote machines.

`zmx` keeps sessions alive and `dvtm` tiles panes on every platform.

## Primitives

| Command | Action |
|---|---|
| `a` | `pi` coding agent (`a [args...]`) |
| `d` | SSH devices (`d [<host> [<cmd>...]]`; no arguments lists, `d -- [<cmd>...]` reads host from stdin) |
| `e` | `nvim` editor (`e [files...]`) |
| `f` | find files (`fd --hidden --follow --exclude .git`) |
| `g` | `git` (`g [args...]`) |
| `h` | manual pages (`man [args...]`) |
| `j` | fuzzy jump to session or workspace (`j [target]`) |
| `k` | keybind legend and config (`k [list [tool] \| edit [tool] \| delete [tool key]]`; `k delete` reads stdin) |
| `l` | list directory (`ls -lahF`) |
| `m` | session multiplexer (`m [list \| [attach] [target] \| detach \| delete [target...]]`; `m attach` and `m delete` read targets from stdin) |
| `s` | search file contents (`rg --hidden --smart-case --glob !.git`) |
| `w` | list workspace paths (`~`, `~/Notes[/<dir>[/<subdir>]]`, `~/Workspaces[/<ctx>[/<proj>]]`) |

## Composition

```sh
w | fzf | m attach                  # pick workspace and attach session
m | fzf | m attach                  # switch active session
m | fzf -m | m delete               # delete selected sessions
d | fzf | d --                      # pick SSH host and connect
d <host> j                          # pick remote session or workspace
d <host> m <session>                # attach remote session directly
k | fzf | k delete                  # delete keybind entry from legend
f | fzf | xargs e                   # find file and open in nvim
```

## Keybinds

- **Leader**: `C-/` in `nvim` and `pi`; `C-g` in `dvtm`.
- **One-letter actions**: `f` files, `s` search, `b` buffers, `o` oldfiles, `w` word or workspaces, `j` jump session, `d` detach or device, `e` editor, `a` agent.
- **Pane controls** (`dvtm`): `C-g j/k` next/prev pane, `C-g h/l` resize master, `C-g Space` cycle layouts, `C-g Enter` zoom to master.

Full reference in [config/keybinds.tsv](config/keybinds.tsv) (`k list [tool]`).

## Remote sessions

`d` runs SSH sessions (`ssh -t`) and remote commands; `m` keeps sessions alive (`d <host> m <session>`). In `~/.ssh/config`, leave `RemoteCommand` unset so `d based j` works:

```sshconfig
Host based
  HostName <host>
  ControlMaster auto
  ControlPath ~/.ssh/cm-%C
  ControlPersist 10m
  ServerAliveInterval 15
  ServerAliveCountMax 3
```

For unstable mobile links with `mosh` installed on both ends: `mosh <host> -- m <session>`.

## Development

```sh
docker run --rm -it --user vscode ghcr.io/lilfeelz/based:latest zsh -l
make test          # lint and unit tests
make test-install  # also verify pinned binary installation
make build         # build image without entering a shell
make run           # start and enter development container
make stop          # remove development container
```

- `make install` picks macOS or Termux (`make build`/`run` on Linux); `make config` installs primitives and config only.
- `ENGINE=docker` overrides the Apple `container` default on macOS; `IMAGE=<image>` overrides the image.
- Installs write primitives to `~/.local/bin` (`$PREFIX/bin` on Termux), configs to `~/.config/based`, and `~/.config/nvim/init.lua` (backing up to `init.lua.based-backup`). Source `~/.config/based/zshrc` from `~/.zshrc` on macOS or pass `BASED_ZSHRC=~/.zshrc`. Tests use temporary homes.
