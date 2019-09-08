SHELL := /bin/bash

BUILD_NAMESPACE ?= greenpeaceinternational

DOCKER_IMAGE_NAME = planet4-vulnerable-plugins-rss

SED_MATCH ?= [^a-zA-Z0-9._-]

ifeq ($(CIRCLECI),true)
# Configure build variables based on CircleCI environment vars
BUILD_NUM = $(CIRCLE_BUILD_NUM)
BRANCH_NAME ?= $(shell sed 's/$(SED_MATCH)/-/g' <<< "$(CIRCLE_BRANCH)")
BUILD_TAG ?= $(shell sed 's/$(SED_MATCH)/-/g' <<< "$(CIRCLE_TAG)")
else
# Not in CircleCI environment, try to set sane defaults
BUILD_NUM = local
BRANCH_NAME ?= $(shell git rev-parse --abbrev-ref HEAD | sed 's/$(SED_MATCH)/-/g')
BUILD_TAG ?= local-tag
endif

dev:
	docker build \
				-t $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):build-$(BUILD_NUM) \
				.
	docker run --rm \
	  -e GOOGLE_CHAT_ROOM_VULNERABLE_PLUGINS_URL="${GOOGLE_CHAT_ROOM_VULNERABLE_PLUGINS_URL}" \
		$(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):build-$(BUILD_NUM)

bash:
	docker run --rm -it \
	  -e GOOGLE_CHAT_ROOM_VULNERABLE_PLUGINS_URL="${GOOGLE_CHAT_ROOM_VULNERABLE_PLUGINS_URL}" \
	  --entrypoint=bash \
		$(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):build-$(BUILD_NUM)


build-tag:
	docker build \
				-t $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):build-$(BUILD_NUM) \
				-t $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):tag-$(BUILD_TAG) \
				-t $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):latest \
				.

build-branch:
	docker build \
				-t $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):build-$(BUILD_NUM) \
				-t $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):$(BRANCH_NAME) \
				.

push-tag:
	docker push $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):build-$(BUILD_NUM)
	docker push $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):tag-$(BUILD_TAG)
	docker push $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):latest

push-branch:
	docker push $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):build-$(BUILD_NUM)
	docker push $(BUILD_NAMESPACE)/$(DOCKER_IMAGE_NAME):$(BRANCH_NAME)
