# lambda-python-template

Quick starter template for new aws lambda python projects.

This is intended to provide a basic project template for deploying Python functions to AWS Lambda. This template is focused on deploying code changes to Lambda. Creating the Lambda function typically involves using an IaC tool like Terraform, CloudFormation, or CDK, however, for convenience, this template contains make commands for quick operations.

## Local

### Setup
```sh
make init
```

### Install dependencies
```sh
make install
```

### Test in python
```sh
make start
```

### Test in container

```sh
make start-container
```
```sh
curl -X POST "http://localhost:8080/2015-03-31/functions/function/invocations" -d '{"hello":"world"}'

{"statusCode": 200, "headers": {"Content-Type": "application/json"}, "body": "{\"event\": {\"hello\": \"world\"}}"}
```


## Deploy

Optionally create the lambda function (IaC is recommended instead)

```sh
# container (default)
make create function=my-function

# zip
make create function=my-function packaging=zip
```

> **Note:** The default architecture is `arm64`. To use x86, pass `arch=x86_64`:
> ```sh
> make create function=my-function arch=x86_64
> ```

### Deploy Code Changes

```sh
# container (default)
make deploy function=my-function

# zip
make deploy function=my-function packaging=zip
```

## Invoke

```sh
make invoke function=my-function
```

## Clean up

```sh
make delete function=my-function
```


## Development

```
 Choose a make command to run

  init               run this once to initialize a new python project
  install            install project dependencies
  start              run local project
  build              package app for aws lambda - make build [packaging=zip]
  role               creates the lambda execution role
  create             creates the lambda function - make create function=my-function [packaging=zip] [arch=x86_64]
  delete             deletes the lambda function - make delete function=my-function
  deploy             deploy code to lambda - make deploy function=my-function [packaging=zip]
  start-container    run local project in container
  push               push container image to ECR - make push function=my-function
  invoke             invoke the lambda function - make invoke function=my-function
```
