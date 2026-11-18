# based

## Purpose
- Demonstrates a composable terminal workspace: small shell commands, plain-text pipes and persistent sessions.
- Uses zsh, Neovim and pi with zmx session persistence and dvtm panes across macOS, Linux containers and Termux.

## Usage
If CI has published the image, try it without installing configuration into your home (availability unverified):

```sh
docker run --rm -it --user vscode ghcr.io/lilfeelz/based:latest zsh -l
```

Build from source instead:

```sh
git clone https://github.com/lilfeelz/based.git
cd based
make test
make build ENGINE=docker
make run ENGINE=docker
```

- `make install`: native macOS/Termux dependencies and config; on Linux it exits with an error. Use `make build`/`make run` instead.
- `make config`: primitives and config only. Both overwrite installed primitives and Neovim config.
- Native destinations: `~/.local/bin`, `~/.config/based`, `~/.config/nvim/init.lua`; Termux uses `$PREFIX/bin`, containers `/usr/local/bin` for binaries.
- Existing Neovim config is copied to `init.lua.based-backup`; repeated installs can replace that backup.
- macOS/config-only: source `~/.config/based/zshrc` from `~/.zshrc`; Termux/container write `~/.zshrc`.
- Engine defaults to Apple `container` on macOS, Docker elsewhere; override `ENGINE` and `IMAGE`.

```sh
w | fzf | m attach       # select workspace, attach persistent session
m | fzf | m attach       # switch session
d | fzf | d --           # select SSH host
file=$(f | fzf) && e "$file" # select one file, preserve spaces
k list                  # display keybinding reference
```

- Primitives: `a` pi, `d` SSH, `e` nvim, `f` fd, `g` git, `h` man, `j` jump, `k` keys, `l` ls, `m` sessions, `s` rg, `w` workspaces.
- `w` discovers home, notes and workspace directories; `d` reads SSH config and optionally Tailscale.
- `d <host> j` selects a remote workspace; `d <host> m <session>` reconnects to a persistent session.
- Keys: `C-/` leader in Neovim/pi; dvtm `C-g j/k` select panes, `h/l` resize, Space layout, Enter zoom.
- Full bindings: [config/keybinds.tsv](config/keybinds.tsv).

## Layout
```text
bin/                 # single-letter commands composed through stdin/stdout
config/              # zsh, Neovim and keybinding reference
install/             # platform installers and checksummed tool pins
run                  # container build/start/stop entrypoint
Makefile             # install, config, test and container commands
test/                # temporary-home command/install and multiplexer tests
.devcontainer/       # Linux image and development environment
.github/             # CI, image-promotion guards and release workflow
```

## Operate
- Owner: lilfeelz. No hosted application; deployment is local install or container image publication.
- `make stop ENGINE=docker` removes the development container, not native installs.
- Rollback: restore saved config/binaries; for a retained image, `make stop ENGINE=docker` then `make run ENGINE=docker IMAGE=<image>`. No native uninstaller or automatic rollback.
- CI: PRs run promotion-guard tests, `make test-install`, then build/save a seven-day image artifact.
- Main publishes that PR artifact only when source-tree and image identity checks pass; no fallback rebuild.
- Release-please owns versions and changelog. No image availability or live host deployment is asserted here.

```sh
make test
make test-install
node --test .github/scripts/image.test.cjs
```

## Dependencies
- Runtime: zsh, Neovim, pi, zmx, dvtm, fzf, fd, ripgrep, git and SSH; optional Tailscale discovery.
- Installation: platform package manager plus curl, jq, tar, checksum tools and C/ncurses build tooling; pins in `install/pins.json`.
- Containers: Docker or Apple `container`; pi requires separately configured model access.
- Tests: Python 3, Node.js and jq; shellcheck/shfmt run when available.

## Status
- Live: source-tested workspace primitives and image-promotion CI; published image availability unverified. Planned: retain as a terminal-composition showcase.
