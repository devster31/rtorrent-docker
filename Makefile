#!/usr/bin/make -f

SHELL = /bin/bash

# envfile ?= .env
# -include $(envfile)
# export $(shell sed 's/=.*//' $(envfile))

# ifdef $(shell command -v gdate 2> /dev/null)
# DATE = gdate -I
# else
# DATE = date +"%Y-%m-%d"
# endif
# TAG = $(shell $(DATE))

# TAG := $(shell date +"%Y%m%d")
TAG := $(shell git rev-parse --short HEAD)

NAME := $(notdir $(CURDIR))
GIT_USER := $(shell git config --global user.name)
GIT_EMAIL := $(shell git config --global user.email)

.PHONY: repo rtorrent rutorrent
build: repo rtorrent rutorrent

repo:
ifneq ($(strip $(shell docker ps -q -f name=$(NAME)-repo)),)
	docker stop $(NAME)-repo
	docker rm $(NAME)-repo
endif
	docker build \
		--build-arg git_user=$(GIT_USER) \
		--build-arg git_email=$(GIT_EMAIL) \
		--compress \
		--file Dockerfile.repo \
		--tag $(NAME)-repo:$(TAG) \
		.
	@echo Image tag: $(NAME)-repo:$(TAG)

rtorrent:
ifeq ($(shell docker network inspect builder 2>/dev/null),[])
	docker network create builder
endif

ifeq ($(strip $(shell docker ps -q -f name=$(NAME)-repo)),)
	docker run -d \
		--name=$(NAME)-repo \
		--network=builder \
		$(NAME)-repo:$(TAG)
endif

PORT ?= 8080
	docker build \
		--build-arg repo_url=$(NAME)-repo \
		--build-arg repo_port=$(PORT) \
		--file Dockerfile.rtorrent \
		--network builder \
		--tag $(NAME):$(TAG) \
		.
	@echo Image: $(NAME):$(TAG)

rutorrent:
	docker build \
		--file Dockerfile.rutorrent \
		--tag $(subst rtorrent,rutorrent,$(NAME)):$(TAG) \
		.
	@echo Image: $(subst rtorrent,rutorrent,$(NAME)):$(TAG)