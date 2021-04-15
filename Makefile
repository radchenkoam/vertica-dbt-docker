.DEFAULT_GOAL:=help

VPWD := $(shell cat ./vertica/.env | sed -n "s/VERTICA_DBA_PASSWORD=//p")
DBT_USER :=	$(shell cat ./dbt/.env | sed -n "s/DBT_USER=//p")
DBT_PROFILES_DIR := $(shell cat ./dbt/.env | sed -n "s/DBT_PROFILES_DIR=//p")

.PHONY: setup
setup: ## Execute setup-script
	sudo ./setup.sh

.PHONY: vertica-run
vertica-run: ## Running a Vertica docker-container
	docker run --name vertica -d \
		--network dbt-net \
		--env-file=./vertica/.env \
		-p 5433:5433/tcp \
		-v $(shell pwd)/vertica/data:/home/dbadmin/vertica_data \
		-t radchenkoam/vertica:latest

.PHONY: vertica-connect
vertica-connect: ## Running a vsql and connect to the Vertica
	/opt/vertica/bin/vsql -h 127.0.0.1 -p 5433 -U dbadmin -w $(VPWD)

.PHONY: dbt-build
dbt-build: ## Building a DBT docker-container
	docker build --no-cache -t radchenkoam/dbt \
		--network dbt-net \
	  --build-arg DBT_USER=$(DBT_USER) \
	  --build-arg DBT_PROFILES_DIR=$(DBT_PROFILES_DIR) ./dbt

.PHONY: dbt-dev
dbt-dev: ## Running a DBT docker-container for dev
	docker run --rm -it radchenkoam/dbt:latest bash

.PHONY: dbt-run
dbt-run: ## Running a DBT docker-container
	docker run --name dbt --rm -it \
		--network dbt-net \
		--entrypoint /bin/bash \
		-v $(shell pwd)/dbt/crimes_in_boston:$(DBT_PROFILES_DIR) \
	  -t radchenkoam/dbt:latest

.PHONY: dbt-version
dbt-version: ## Show DBT version in docker-container
	docker run --rm -it radchenkoam/dbt:latest dbt --version

.PHONY: help
help: ## Show this help message.
	@echo 'usage: make [target]'
	@echo
	@echo 'targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
	@echo

dbt-args:
	@echo DBT_USER=$(DBT_USER)
	@echo DBT_PROFILES_DIR=$(DBT_PROFILES_DIR)

# .PHONY: push
# push:
# 	docker push
