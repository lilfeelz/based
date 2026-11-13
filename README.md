# based

Minimal devcontainer for persistent [zmx](https://github.com/neurosnap/zmx) sessions, with dvtm, nvim, and fzf-lua. Installs on macOS and Termux outside a container too.

## Run

```sh
./run     # build and enter the persistent container
j         # attach the project session
nvim
```

`j` jumps to another session when already inside one. `j name` creates or switches to a named session. `./run stop` removes the container.

Apple `container` needs the GUI session. If `./run` says so, run it from Terminal.app. VS Code Dev Containers work too.

## Install outside the container

```sh
./install/macos.sh    # Homebrew dependencies, zmx, fzf-lua, nvim config, j
./install/termux.sh   # Termux packages, zmx, fzf-lua, nvim config, j
```

The devcontainer image runs `install/container.sh` from the Dockerfile.

macOS has no dvtm package, so `j` runs `nvim -c term -c startinsert` there. Termux and the container image use dvtm. Add `~/.local/bin` to `PATH` on macOS if the installer asks.

## Keys

- nvim: `Space ff/fg/fw/fb/fr` files, grep, word, buffers, recent; `Space j` jump; `Space d` detach
- dvtm (Termux and image): `Ctrl+A` prefix; `Ctrl+A ?` help
- fzf: `Ctrl+T`, `Ctrl+R`, `Alt+C`
