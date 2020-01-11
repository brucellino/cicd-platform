# Repo for the CI/CD pipeline

This is the repo for the CI/CD pipeline.

The platform is made up of:

- cloud envelope
- Vault secrets management svg-coverity-stream
- Distributed storage
  - Jenkins master configuration
  - Jenkins artifacts
- Jenkins master instance
- Jenkins cloud agent envelopes
  - EC2
  - ECS

This repo should contain all of the code and components necessary to deploy the
platform from scratch.

## Cloud envelope

The cloud envelope will differ depending on which cloud you are deploying to.
Each cloud should have its own Terraform module.
