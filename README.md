# lambda-python-template

Quick starter template for new aws lambda python projects.

This is intended to provide a basic project template for deploying Python functions to AWS Lambda. This template is focused on deploying code changes to Lambda. Creating the Lambda function typically involves using an IaC tool like Terraform, CloudFormation, or CDK, however, for convenience, this template contains a make create command to also create a function.

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
make create function=my-function
```

### Deploy Code Changes

Template supports both container and zip formats

#### Container

```sh
make deploy-container function=my-function
```

#### Zip

```sh
make deploy-zip function=my-function
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
  build-zip          package app for aws lambda using zip
  role               creates the lambda execution role
  create             creates the lambda function - make create function=my-function
  delete             deletes the lambda function - make delete function=my-function
  deploy-zip         deploy code to lambda as zip - make deploy-zip function=my-function
  build-container    package app for aws lambda using container
  start-container    run local project in container
  deploy-container   deploy code to lambda as container - make deploy-container function=my-function
  invoke             invoke the lambda function - make invoke function=my-function
```
