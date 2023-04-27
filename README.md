# lambda-python-template

Quick starter template for new aws lambda python projects.

This is intended to provide a basic project template for deploying Python functions to AWS Lambda.  The scope of this template is deploying code changes to lambda.  It does not handle creating a lambda function and assumes you will use an IaC tool like Terraform, CloudFormation, or CDK to do that.

setup
```sh
make init
```

deploy
```sh
make deploy function=my-function
```

```
 Choose a make command to run

  init      run this once to initialize a new python project
  install   install project dependencies
  start     run local project
  build     package app for aws lambda
  deploy    deploy function code to aws lambda
```

