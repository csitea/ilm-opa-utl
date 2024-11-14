.PHONY: tf-new-step ## @-> 03.00 generates framework for terraform new step
tf-new-step: demand_var-STEP
	./run -a do_tf_new_step

.PHONY: tf-remove-step ## @-> 03.00 generates framework for terraform new step
tf-remove-step: demand_var-STEP
	./run -a do_tf_remove_step


.PHONY: do-tf-plan ## @-> 03.01 saves a terraform plan
do-tf-plan: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		-e ACTION=provision \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_plan


.PHONY: do-import ## @-> 03.02 import terraform resource
do-import: demand_var-AWS_PROFILE demand_var-ENV demand_var-ORG demand_var-APP demand_var-TF_PROJ \
demand_var-RESOURCE_ADDRESS demand_var-RESOURCE_IDENTIFIER demand_var-STEP
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e AWS_PROFILE=$(AWS_PROFILE) \
		-e RESOURCE_ADDRESS=$(RESOURCE_ADDRESS) \
		-e RESOURCE_IDENTIFIER=$(RESOURCE_IDENTIFIER) \
		-e TF_PROJ=$(TF_PROJ) \
		-e STEP=$(STEP) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_import


.PHONY: do-provision ## @-> 03.03 provision a step
do-provision: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		-e ACTION=provision \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_provision


.PHONY: do-tf-apply-target ## @-> 03.04 provision target resource only
do-tf-apply-target: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP demand_var-TARGET
	@ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e TARGET="$(TARGET)" \
		-e STEP=$(STEP) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_apply_target

.PHONY: do-divest ## @-> 03.05 divest  a step only
do-divest: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP
	@ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		-e GIT_REF=$(GIT_REF) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_divest

.PHONY: do-provision-local ## @-> 03.07 provision a step
do-provision-local: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP
	@ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_provision_local

.PHONY: do-divest-local ## @-> 03.08 divest  a step only
do-divest-local: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP
	@ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_divest_local

.PHONY: do-tf-destroy-target ## @-> 03.09 divest target resource only
do-tf-destroy-target: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP demand_var-TARGET
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) -e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e TARGET="$(TARGET)" \
		-e STEP=$(STEP) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_destroy_target

.PHONY: do-tf-import ## @-> 03.10 import target resource to state
do-tf-import: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP demand_var-RESOURCE_ADDRESS demand_var-ID
	export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@echo docker exec \
		-e ORG=$(ORG) \
		-e \SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		-e RESOURCE_ADDRESS="$(RESOURCE_ADDRESS)" \
		-e ID=$(ID) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_import


.PHONY: do-tf-replace-target ## @-> 03.11 reprovision (destroy/recreates) terraform resource
do-tf-replace-target: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP demand_var-TARGET
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e TARGET="$(TARGET)" \
		-e STEP=$(STEP) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_replace_target

.PHONY: do-tf-taint-target ## @-> 03.12 import terraform resource
do-tf-taint-target: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP demand_var-TARGET
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e TARGET="$(TARGET)" \
		-e STEP=$(STEP) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_taint_target

.PHONY: do-tf-untaint-target ## @-> 03.13 import terraform resource
do-tf-untaint-target: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP demand_var-TARGET
	@ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e TARGET="$(TARGET)" \
		-e STEP=$(STEP) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_untaint_target


.PHONY: do-tf-state-list ## @-> 03.14 list the objects in the terraform state
do-tf-state-list: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_state_list

.PHONY: do-tf-state-pull ## @-> 03.15 pull remote state from s3
do-tf-state-pull: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_state_pull

.PHONY: do-tf-state-push ## @-> 03.16 push state to s3
do-tf-state-push: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP demand_var-TFSTATE_FILE
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		-e TFSTATE_FILE=$(TFSTATE_FILE) \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_state_push

.PHONY: do-tf-state-remove ## @-> 03.17 remove target resource from state
do-tf-state-remove: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP demand_var-TARGET
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		-e TARGET="$(TARGET)" \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_state_remove

.PHONY: do-tf-state-show ## @-> 03.18 remove target resource from state
do-tf-state-show: demand_var-ENV demand_var-ORG demand_var-APP demand_var-STEP demand_var-TARGET
	@export ORG=$(ORG) APP=$(APP) ENV=$(ENV)
	@docker exec \
		-e ORG=$(ORG) \
		-e SKIP_GIT_CLONE=$(SKIP_GIT_CLONE) \
		-e ENV=$(ENV) \
		-e APP=$(APP) \
		-e STEP=$(STEP) \
		-e TARGET="$(TARGET)" \
		con-$(ORG)-$(APP)-tf-runner \
		./run -a do_tf_state_show
