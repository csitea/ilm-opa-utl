.PHONY: do-echo-attach-exec-adminer
do-echo-attach-exec-adminer:
	@echo to attach to the containers do:
	@echo docker exec -it foobar-1 /bin/bash

.PHONY: do-setup-adminer  ## @-> 01.02 setup the whole ilm-opa dockerized setup
do-setup-adminer: demand_var-GITHUB_TOKEN
	@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} down --rmi all \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} --verbose build \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} --verbose up -d
	@$(MAKE) do-echo-attach-exec-adminer

.PHONY: do-setup-adminer-no-cache  ## @-> 01.03 setup the whole ilm-opa dockerized setup
do-setup-adminer-no-cache: demand_var-GITHUB_TOKEN
	@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} down --rmi all \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} --verbose build --no-cache \
	&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_ADMINER} --verbose up -d
	@$(MAKE) do-echo-attach-exec-adminer
