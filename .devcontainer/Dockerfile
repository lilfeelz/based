FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive \
    EDITOR=nvim \
    SHELL=/bin/zsh \
    ZMX_NO_DETACH_KEY=1

COPY bin /tmp/based/bin
COPY config /tmp/based/config
COPY install /tmp/based/install

RUN BASED_HOME=/home/vscode sh /tmp/based/install/container.sh \
 && rm -rf /tmp/based
