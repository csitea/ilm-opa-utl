.PHONY: do-list-containers  ## @-> 08.00 list the running containers
do-list-containers:
		@clear ; docker ps --format '{{.Names}}'
