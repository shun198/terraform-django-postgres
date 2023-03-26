RUN_TERRAFORM = docker-compose -f infra/docker-compose.yml run --rm terraform
DURATION = 12h


init:
	$(RUN_TERRAFORM) init

fmt:
	$(RUN_TERRAFORM) fmt

validate:
	$(RUN_TERRAFORM) validate

show:
	$(RUN_TERRAFORM) show

apply:
	$(RUN_TERRAFORM) apply -auto-approve

graph:
	$(RUN_TERRAFORM) graph | dot -Tsvg > graph.svg

list_workspace:
	$(RUN_TERRAFORM) workspace list

dev_workspace:
	$(RUN_TERRAFORM) workspace new dev

stg_workspace:
	$(RUN_TERRAFORM) workspace new stg

prd_workspace:
	$(RUN_TERRAFORM) workspace new prd

destroy:
	$(RUN_TERRAFORM) destroy