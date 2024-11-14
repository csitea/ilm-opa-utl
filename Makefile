# Makefile
# usage: run the "make" command in the root, than make <<cmd>>...
include $(wildcard src/docker/.env)
export
include $(wildcard lib/make/*.mk)
include $(wildcard src/make/*.func.mk)


# set ALL of your global variables here, setting vars in functions outsite the funcs does not work
export UID := $(shell id -u)
export GID := $(shell id -g)
BUILD_NUMBER := $(if $(BUILD_NUMBER),$(BUILD_NUMBER),"0")
COMMIT_SHA := $(if $(COMMIT_SHA),$(COMMIT_SHA),$$(git rev-parse --short HEAD))
COMMIT_MESSAGE := $(if $(COMMIT_MESSAGE),$(COMMIT_MESSAGE),$$(git log -1  --pretty='%s'))
DOCKER_BUILDKIT := $(or 1,$(shell echo $$DOCKER_BUILDKIT))

SHELL = bash
PROJ := $(shell basename $$PWD)
PROJ := $(shell echo `basename $$PWD`|tr '[:upper:]' '[:lower:]')
product := $(shell echo `basename $$PWD`|tr '[:upper:]' '[:lower:]')
PROCESSOR_ARCHITECTURE := $(shell uname -m)

DOCKER_COMPOSE_FILE_WPP_INF := "src/docker/docker-compose-infra.yaml"
DOCKER_COMPOSE_FILE_LOCAL_DEV := "src/docker/docker-compose-wpp-local-dev-setup.yaml"

.DEFAULT_GOAL := usage



# eof file: /opt/ilm/wpp/ilm-opa-utl/Makefile
