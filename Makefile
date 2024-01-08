## Initialise OIDC provider
init-oidc:
	docker-compose run --rm terraform-utils sh -c 'cd aws-oidc; terraform init'

create-oidc: init-oidc
	docker-compose run --rm terraform-utils sh -c 'cd aws-oidc; terraform apply -auto-approve'
.PHONY: create-oidc

destroy-oidc: init-oidc
	docker-compose run --rm terraform-utils sh -c 'cd aws-oidc; terraform destroy -auto-destroy'
.PHONY: create-oidc


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