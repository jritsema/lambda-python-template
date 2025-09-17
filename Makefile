ROLE_NAME = lambda-basic-execution

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

## build-zip: package app for aws lambda using zip
.PHONY: build-zip
build-zip:
	./zip.sh

## role: creates the lambda execution role
.PHONY: role
role:
	aws iam create-role --role-name ${ROLE_NAME} --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{"Effect": "Allow","Principal": {"Service": "lambda.amazonaws.com"},"Action": "sts:AssumeRole"}]}' || true
	aws iam attach-role-policy --role-name ${ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole || true

## create: creates the lambda function - make create function=my-function
.PHONY: create
create: build-zip role
	aws lambda create-function \
		--function-name ${function} \
		--runtime python3.13 \
		--handler lambda_function.lambda_handler \
		--role $$(aws sts get-caller-identity --query Account --output text | xargs -I {} echo "arn:aws:iam::{}:role/${ROLE_NAME}") \
		--zip-file fileb://lambda.zip

## delete: deletes the lambda function - make delete function=my-function
.PHONY: delete
delete:
	aws lambda delete-function --function-name ${function}

## deploy-zip: deploy code to lambda as zip - make deploy-zip function=my-function
.PHONY: deploy-zip
deploy-zip: build-zip
	aws lambda update-function-code --function-name ${function} --zip-file fileb://lambda.zip

## build-container: package app for aws lambda using container
.PHONY: build-container
build-container:
	docker build -t lambda .

## start-container: run local project in container
.PHONY: start-container
start-container: build-container
	clear
	@echo ""
	docker run -it --rm -p 8080:8080 lambda

## deploy-container: deploy code to lambda as container - make deploy-container function=my-function
.PHONY: deploy-container
deploy-container: build-container
	./deploy.sh ${function}

## invoke: invoke the lambda function - make invoke function=my-function
.PHONY: invoke
invoke:
	aws lambda invoke \
		--function-name ${function} \
		--payload file://request.json \
		--cli-binary-format raw-in-base64-out \
		response.json
	cat response.json
