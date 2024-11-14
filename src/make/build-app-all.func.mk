.PHONY: do-build-app-all ## @-> 08.00 build both the backend and the front-end
do-build-app-all:
		docker exec $(WUI_CONTAINER_NAME) /bin/bash -c "cd $(WUI_PROJ_PATH) && npm run build"
		echo todo-backend

.PHONY: build-app-all ## @-> 08.01 build both the backend and the front-end natively
build-app-all:
		cd $(WUI_PROJ_PATH) && \
		npm run lint
