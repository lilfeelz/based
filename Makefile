.DEFAULT_GOAL := help
ENGINE ?= $(if $(filter Darwin,$(shell uname -s)),container,docker)
IMAGE ?= ghcr.io/lilfeelz/based:latest
export BASED_CONTAINER = $(ENGINE)
export BASED_IMAGE = $(IMAGE)

.PHONY: help install config test test-install build run stop
help:
	@printf '%s\n' 'install       install on macOS or Termux' \
	  'config        install primitives and configuration' \
	  'test          lint and unit tests' \
	  'test-install  also test pinned binary installation' \
	  'build         build the container image' \
	  'run           start and enter the container' \
	  'stop          remove the development container'

install:
	@if [ -n "$${TERMUX_VERSION:-}" ]; then sh install/termux.sh; \
	elif [ "$$(uname -s)" = Darwin ]; then sh install/macos.sh; \
	else printf 'based: native install supports macOS and Termux; use make build/run on Linux\n' >&2; exit 1; fi

config:
	sh install/common.sh config

test:
	./test/run

test-install:
	./test/run --install

build:
	./run build

run:
	./run

stop:
	./run stop
