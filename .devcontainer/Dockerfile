FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ENV DEBIAN_FRONTEND=noninteractive \
    EDITOR=nvim \
    ZMX_NO_DETACH_KEY=1

COPY install /tmp/based/install
COPY .devcontainer /tmp/based/.devcontainer

RUN BASED_HOME=/home/vscode sh /tmp/based/install/devcontainer.sh \
 && rm -rf /tmp/based
