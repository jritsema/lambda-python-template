ROLE_NAME = lambda-basic-execution
PYTHON_VERSION = $(shell grep python .tool-versions | awk '{print $$2}' | cut -d. -f1,2)
arch ?= arm64
DOCKER_PLATFORM = $(if $(filter arm64,$(arch)),linux/arm64,linux/amd64)

all: help

.PHONY: help
help: Makefile
	@echo
	@echo " Choose a make command to run"
	@echo
	@sed -n 's/^##//p' $< | column -t -s ':' |  sed -e 's/^/ /'
	@echo

## init: run this once to initialize a new python project
.PHONY: init
init:
	python -m venv .venv
	direnv allow .

## install: install project dependencies
.PHONY: install
install:
	python -m pip install --upgrade pip
	pip install -r requirements.txt

## start: run local project
.PHONY: start
start:
	clear
	@echo ""
	python main.py

## build: package app for aws lambda - make build [packaging=zip]
.PHONY: build
build:
	$(if $(filter container,$(packaging)),$(MAKE) _build-container,$(MAKE) _build-zip)

.PHONY: _build-zip
_build-zip: install
	cd .venv/lib/python$(PYTHON_VERSION)/site-packages && zip -r ../../../../lambda.zip .
	zip -g lambda.zip *.py

## role: creates the lambda execution role
.PHONY: role
role:
	aws iam create-role --role-name $(ROLE_NAME) --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{"Effect": "Allow","Principal": {"Service": "lambda.amazonaws.com"},"Action": "sts:AssumeRole"}]}' || true
	aws iam attach-role-policy --role-name $(ROLE_NAME) --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole || true

## create: creates the lambda function - make create function=my-function [packaging=zip] [arch=x86_64]
packaging ?= container
.PHONY: create
create: role
	@echo "Waiting for IAM role to propagate..."
	sleep 10
	$(if $(filter container,$(packaging)),$(MAKE) _create-container function=$(function),$(MAKE) _create-zip function=$(function))

.PHONY: _create-container
_create-container: _build-container
	$(eval IMAGE := $(shell $(MAKE) -s push function=$(function)))
	$(eval ACCOUNT := $(shell aws sts get-caller-identity --query Account --output text))
	aws lambda create-function \
		--function-name $(function) \
		--package-type Image \
		--code ImageUri=$(IMAGE) \
		--architectures $(arch) \
		--role arn:aws:iam::$(ACCOUNT):role/$(ROLE_NAME)

.PHONY: _create-zip
_create-zip: _build-zip
	$(eval ACCOUNT := $(shell aws sts get-caller-identity --query Account --output text))
	aws lambda create-function \
		--function-name $(function) \
		--runtime python$(PYTHON_VERSION) \
		--handler lambda_function.lambda_handler \
		--role arn:aws:iam::$(ACCOUNT):role/$(ROLE_NAME) \
		--architectures $(arch) \
		--zip-file fileb://lambda.zip

## delete: deletes the lambda function - make delete function=my-function
.PHONY: delete
delete:
	aws lambda delete-function --function-name $(function)

## deploy: deploy code to lambda - make deploy function=my-function [packaging=zip]
.PHONY: deploy
deploy:
	$(if $(filter container,$(packaging)),$(MAKE) _deploy-container function=$(function),$(MAKE) _deploy-zip function=$(function))

.PHONY: _deploy-zip
_deploy-zip: _build-zip
	aws lambda update-function-code --function-name $(function) --zip-file fileb://lambda.zip

.PHONY: _build-container
_build-container:
	docker build --platform $(DOCKER_PLATFORM) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) -t lambda .

## start-container: run local project in container
.PHONY: start-container
start-container: _build-container
	clear
	@echo ""
	docker run -it --rm -p 8080:8080 lambda

## push: push container image to ECR - make push function=my-function
.PHONY: push
push:
	$(eval ACCOUNT := $(shell aws sts get-caller-identity --query Account --output text))
	$(eval REPO_NAME := $(function))
	@aws ecr get-login-password --region $(AWS_REGION) | docker login --username AWS --password-stdin $(ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com >&2
	@aws ecr describe-repositories --repository-names $(REPO_NAME) >/dev/null 2>&1 || aws ecr create-repository --repository-name $(REPO_NAME) >&2
	$(eval URI := $(shell aws ecr describe-repositories --repository-names $(REPO_NAME) --query 'repositories[0].repositoryUri' --output text))
	$(eval IMAGE := $(URI):latest)
	docker buildx build --push --provenance=false --platform $(DOCKER_PLATFORM) --build-arg PYTHON_VERSION=$(PYTHON_VERSION) -t $(IMAGE) . >&2
	@echo $(IMAGE)

.PHONY: _deploy-container
_deploy-container:
	$(eval IMAGE := $(shell $(MAKE) -s push function=$(function)))
	aws lambda update-function-code --function-name $(function) --image-uri $(IMAGE)

## invoke: invoke the lambda function - make invoke function=my-function
.PHONY: invoke
invoke:
	aws lambda invoke \
		--function-name $(function) \
		--payload file://request.json \
		--cli-binary-format raw-in-base64-out \
		response.json
	cat response.json
