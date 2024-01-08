## OIDC infrastructure
init-oidc:
	docker-compose run --rm terraform-utils sh -c 'cd aws-oidc; terraform init'
.PHONY: init-oidc

create-oidc: init-oidc
	docker-compose run --rm terraform-utils sh -c 'cd aws-oidc; terraform apply -auto-approve'
.PHONY: create-oidc

destroy-oidc: init-oidc
	docker-compose run --rm terraform-utils sh -c 'cd aws-oidc; terraform destroy -auto-destroy'
.PHONY: destroy-oidc

##VPC
init-vpc:
	docker-compose run --rm terraform-utils sh -c 'cd vpc; terraform init'
.PHONY: init-vpc

create-vpc: init-vpc
	docker-compose run --rm terraform-utils sh -c 'cd vpc; terraform apply -auto-approve'
.PHONY: create-vpc

destroy-vpc: init-vpc
	docker-compose run --rm terraform-utils sh -c 'cd vpc; terraform destroy -auto-approve'
.PHONY: destroy-vpc


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


## Destroy everything
destroy-all: destroy-vpc destroy-oidc
	echo "finished destroying everyting"
.PHONY: destroy-all