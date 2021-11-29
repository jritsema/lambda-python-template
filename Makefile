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
	python3 -m venv .venv
	direnv allow .

## install: install project dependencies
.PHONY: install
install:
	pip install -r requirements.txt

## start: run local project
.PHONY: start
start:
	clear
	@echo ""
	python main.py

## build: package app for aws lambda
.PHONY: build
build:
	./build.sh

## deploy: deploy function code to aws lambda
.PHONY: deploy
deploy: build
	aws lambda update-function-code \
		--function-name ${FUNCTION_NAME} \
		--zip-file fileb://lambda.zip