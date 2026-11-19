# based

A composable terminal workspace: small single-purpose commands, plain-text pipes and
persistent sessions. zsh, Neovim and pi on macOS, Linux containers and Termux.

```text
  w ──▶ fzf ──▶ m attach ──▶ dvtm panes ──▶ zsh / nvim / pi
  d ──▶ fzf ──▶ ssh host ──▶ zmx session (persists across disconnects)
```

## Quickstart

```sh
git clone https://github.com/lilfeelz/based.git
cd based
make test
make build ENGINE=docker
make run ENGINE=docker
```

Without installing anything into your home directory:

```sh
docker run --rm -it --user vscode ghcr.io/lilfeelz/based:latest zsh -l
```

## Primitives

| Command | Does |
|---|---|
| `a` | pi |
| `d` | ssh, optionally from the Tailscale host list |
| `e` | nvim |
| `f` | fd |
| `g` | git |
| `h` | man |
| `j` | jump |
| `k` | keybinding reference |
| `l` | ls |
| `m` | sessions |
| `s` | rg |
| `w` | workspaces |

```sh
w | fzf | m attach           # pick a workspace, attach its session
d | fzf | d --               # pick a host
file=$(f | fzf) && e "$file" # pick one file, keep spaces
```

Full bindings: [config/keybinds.tsv](config/keybinds.tsv).

## Install

- `make install`: native macOS and Termux dependencies plus config. On Linux it exits with an error; use `make build`/`make run`.
- `make config`: primitives and config only. Overwrites installed primitives and the Neovim config; the existing `init.lua` is backed up to `init.lua.based-backup`.
- Destinations: `~/.local/bin`, `~/.config/based`, `~/.config/nvim/init.lua`; Termux uses `$PREFIX/bin`, containers `/usr/local/bin`.
- Source `~/.config/based/zshrc` from `~/.zshrc` on macOS; Termux and containers write `~/.zshrc`.
- `ENGINE` defaults to Apple `container` on macOS and Docker elsewhere.

## Layout

```text
bin/           single-letter commands composed through stdin/stdout
config/        zsh, Neovim and keybinding reference
install/       platform installers and checksummed tool pins
run            container build/start/stop entrypoint
Makefile       install, config, test and container commands
test/          temporary-home command and multiplexer tests
```

## Development

```sh
make test
make test-install
node --test .github/scripts/image.test.cjs
```

Runtime dependencies: zsh, Neovim, pi, zmx, dvtm, fzf, fd, ripgrep, git and SSH.
Containers need Docker or Apple `container`; pi needs its own model access configured.

## License

See [LICENSE](LICENSE).
