# based

Minimal Apple `container` devcontainer for persistent [zmx](https://github.com/neurosnap/zmx) sessions, with dvtm, nvim, and fzf-lua.

## Run

```sh
./run     # build and enter the persistent container
j         # attach the project session with dvtm
nvim
```

`j` jumps to another session when already inside one. `j name` creates or switches to a named session. `./run stop` removes the container.

Apple `container` needs the GUI session. If `./run` says so, run it from Terminal.app. VS Code Dev Containers work too.

## Keys

- nvim: `Space ff/fg/fw/fb/fr` files, grep, word, buffers, recent; `Space j` jump; `Space d` detach
- dvtm: `Ctrl+A` prefix; `Ctrl+A ?` help
- fzf: `Ctrl+T`, `Ctrl+R`, `Alt+C`
