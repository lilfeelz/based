FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive \
    EDITOR=nvim \
    ZMX_NO_DETACH_KEY=1

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bash-completion bat ca-certificates curl dvtm fd-find fzf git neovim ripgrep \
 && rm -rf /var/lib/apt/lists/* \
 && ln -sf /usr/bin/batcat /usr/local/bin/bat \
 && ln -sf /usr/bin/fdfind /usr/local/bin/fd \
 && mkdir -p /usr/local/share/fzf \
 && curl -fsSL -o /usr/local/share/fzf/key-bindings.bash \
      "https://raw.githubusercontent.com/junegunn/fzf/$(fzf --version | cut -d' ' -f1)/shell/key-bindings.bash"

ARG ZMX_VERSION=0.8.1
RUN set -eu; \
    case "$(dpkg --print-architecture)" in \
      amd64) arch=x86_64 ;; \
      arm64) arch=aarch64 ;; \
      *) echo "unsupported arch" >&2; exit 1 ;; \
    esac; \
    asset="zmx-${ZMX_VERSION}-linux-${arch}.tar.gz"; \
    tmp="$(mktemp -d)"; \
    curl -fsSL -o "$tmp/$asset" "https://github.com/neurosnap/zmx/releases/download/v${ZMX_VERSION}/${asset}"; \
    curl -fsSL -o "$tmp/$asset.sha256" "https://github.com/neurosnap/zmx/releases/download/v${ZMX_VERSION}/${asset}.sha256"; \
    echo "$(cut -d' ' -f1 "$tmp/$asset.sha256")  $tmp/$asset" | sha256sum -c -; \
    tar xzf "$tmp/$asset" -C "$tmp"; \
    install -m 0755 "$tmp/zmx" /usr/local/bin/zmx; \
    rm -rf "$tmp"

RUN mkdir -p /opt/fzf-lua \
 && curl -fsSL https://github.com/ibhagwan/fzf-lua/archive/ded1c96d3d9d74634287d722431c26690968a4bf.tar.gz \
    | tar xz -C /opt/fzf-lua --strip-components=1

COPY .devcontainer/j /usr/local/bin/
COPY .devcontainer/init.lua /home/vscode/.config/nvim/init.lua
COPY .devcontainer/bashrc /home/vscode/.bashrc

RUN chmod 0755 /usr/local/bin/j \
 && chown -R vscode:vscode /home/vscode/.config /home/vscode/.bashrc
