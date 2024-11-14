.PHONY: do-echo-attach-exec
do-echo-attach-exec:
	@echo to attach to the containers do:
	@echo docker exec -it foobar-1 /bin/bash

.PHONY: do-setup-app-inf  ## @-> 01.02 setup the whole ilm-opa dockerized setup
do-setup-app-inf: demand_var-GITHUB_TOKEN
	@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_WPP_INF} down --rmi all \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_WPP_INF} --verbose build \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_WPP_INF} --verbose up -d
	@$(MAKE) do-echo-attach-exec

.PHONY: do-setup-app-inf-no-cache  ## @-> 01.03 setup the whole ilm-opa dockerized setup
do-setup-app-inf-no-cache: demand_var-GITHUB_TOKEN
	@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_WPP_INF} down --rmi all \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_WPP_INF} --verbose build --no-cache \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_WPP_INF} --verbose up -d
	@$(MAKE) do-echo-attach-exec

.PHONY: do-setup-app-inf-up  ## @-> 01.02 setup the whole ilm-opa dockerized setup
do-setup-app-inf-up: demand_var-GITHUB_TOKEN
	@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_wpb_INF} down --rmi all \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_wpb_INF} --verbose up -d
	@$(MAKE) do-echo-attach-exec
