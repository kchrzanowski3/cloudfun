## OIDC infrastructure
init-oidc:
	docker-compose run --rm terraform-utils sh -c 'cd aws-oidc; terraform init'
.PHONY: init-oidc

oidc: init-oidc
	docker-compose run --rm terraform-utils sh -c 'cd aws-oidc; terraform apply -auto-approve'
.PHONY: init-oidc

destroy-oidc: init-oidc
	docker-compose run --rm terraform-utils sh -c 'cd aws-oidc; terraform destroy -auto-destroy'
.PHONY: destroy-oidc

##infra
init-infra:
	docker-compose run --rm terraform-utils sh -c 'cd infra; terraform init'
.PHONY: init-infra

infra-plan: init-oidc
	docker-compose run --rm terraform-utils sh -c 'cd aws-oidc; terraform plan'
.PHONY: plan-oidc

infra: init-infra
	docker-compose run --rm terraform-utils sh -c 'cd infra; terraform apply -auto-approve'
.PHONY: infra

destroy-infra: init-infra
	docker-compose run --rm terraform-utils sh -c 'cd infra; terraform destroy -auto-approve'
.PHONY: destroy-infra


##used during development, create any other folder
## Initialise
init:
	docker-compose run --rm terraform-utils sh -c 'cd $(TERRAFORM_ROOT_MODULE); terraform init'
.PHONY: init

## Plan
plan: init
	docker-compose run --rm terraform-utils sh -c 'cd ${TERRAFORM_ROOT_MODULE}; terraform plan'
.PHONY: plan

## Apply
apply: init
	docker-compose run --rm terraform-utils sh -c 'cd ${TERRAFORM_ROOT_MODULE}; terraform apply -auto-approve'
.PHONY: apply

## Destroy
destroy: init
	docker-compose run --rm terraform-utils sh -c 'cd ${TERRAFORM_ROOT_MODULE}; terraform destroy -auto-approve'
.PHONY: destroy


## Make everything
build: oidc infra
	echo "finished building everyting"
.PHONY: build



## Destroy everything
destroy-all: destroy-infra destroy-oidc
	echo "finished destroying everyting"
.PHONY: destroy-all