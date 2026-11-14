# based

Composable terminal workspace for macOS, Linux and Termux, built around `zsh`, `nvim` and `pi`. Everything is driven by single-letter commands in `bin/` that read and write plain text lines so they compose with `fzf` and Unix pipes across local and remote machines:

- **Android (Termux)** and **Linux / Container**: `zmx` for persistent sessions and `dvtm` for pane tiling.
- **macOS**: `rex` for sessions and `rift` for window tiling.

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
d <host> j                          # pick remote session or workspace
d <host> m <session>                # attach remote session directly
k | fzf | k delete                  # delete keybind entry from legend
f | fzf | xargs e                   # find file and open in nvim
```

## Keybinds

Bindings follow consistent patterns across `zsh`, `nvim`, `pi`, `dvtm`, and `rex` (plus `rift` on macOS):

- **Leader**: `C-/` across `nvim`, `pi`, and `dvtm` (`Cmd` in `rex`, `CAG` / `Hyper` in `rift`).
- **One-letter actions**: `f` files, `s` search, `b` buffers, `o` oldfiles, `w` word or workspaces, `j` jump session, `d` detach or device, `e` editor, `a` agent.
- **Navigation and layout**: `h/j/k/l` directional focus, move, and resize; `i/o` prev/next workspace; `n/N` next/prev window or match; `Space` cycle layout or open Rex; `Enter` zoom pane to master.

Full reference in [config/keybinds.tsv](config/keybinds.tsv) (or run `k list [tool]`).

## Remote sessions

`d` uses SSH for terminal sessions and remote commands. `m` keeps the session alive through disconnection; reconnect with `d <host> m <session>`.

The [zmx SSH workflow](https://zmx.sh/ssh) recommends connection sharing and optional `autossh` reconnects. For a development host in `~/.ssh/config`:

```sshconfig
Host based
  HostName <host>
  ControlMaster auto
  ControlPath ~/.ssh/cm-%C
  ControlPersist 10m
  ServerAliveInterval 15
  ServerAliveCountMax 3
```

`ControlPersist` keeps an idle connection available; it does not reconnect a broken one. Unlike zmx's dedicated session aliases, leave `RemoteCommand` unset here so `d based j` and other explicit commands work. `d` already requests a terminal with `ssh -t`.

[Mosh](https://mosh.org/) adds roaming and predictive typing over UDP, but only synchronizes the visible screen, so native terminal scrollback is incomplete. It is optional for unstable mobile links: install it at both ends and use `mosh <host> -- m <session>`. Persistent sessions and connection roaming solve different problems.

## Development

Run `make` for the command list. `make install` selects the macOS or Termux installer; Linux uses the container image. `make config` installs only primitives and configuration.

```sh
make test          # lint and unit tests
make test-install  # also verify pinned binary installation
make build         # build the image without entering a shell
make run           # start and enter the development container
make stop          # remove the development container
```

The engine defaults to Apple `container` on macOS and Docker elsewhere. Override with `ENGINE=docker`; `IMAGE=<image>` selects the image for both build and run. Native installs and `make config` write to your home directory; tests use temporary homes.
