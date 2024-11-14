# Determine the Docker Compose command based on OS
DOCKER_COMPOSE_CMD := $(shell [ $$(uname -s) != "Linux" ] && echo "docker compose" || echo "docker-compose")

.PHONY: do-setup-app-local-dev  ## @-> 07.00 setup the whole wpp dockerized setup
do-setup-app-local-dev:
		@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_LOCAL_DEV} down --rmi all \
		&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_LOCAL_DEV} build --no-cache \
		&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_LOCAL_DEV} up -d

.PHONY: do-setup-app-local-dev-cached  ## @-> 07.01 setup the whole wpp dockerized setup by re-using cached docker imgs
do-setup-app-local-dev-cached:
		@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_LOCAL_DEV} down  \
		&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_LOCAL_DEV} build \
		&& ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_LOCAL_DEV} up -d

.PHONY: do-stop-app-local-dev  ## @-> 07.02 stop the composer
do-stop-app-local-dev:
		@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_LOCAL_DEV} down

.PHONY: do-start-app-local-dev ## @-> 07.03 start the composer
do-start-app-local-dev:
		@export DOCKER_BUILDKIT=1; ${DOCKER_COMPOSE_CMD} -f ${DOCKER_COMPOSE_FILE_LOCAL_DEV} up -d
