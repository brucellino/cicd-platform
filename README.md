# Repo for the CI/CD pipeline

This is the repo for the CI/CD pipeline.

The platform is made up of:

- cloud envelope
- Vault secrets management platform
- Distributed storage
  - Jenkins master configuration
  - Jenkins artifacts
- Jenkins master instance
- Jenkins cloud agent envelopes
  - EC2
  - ECS
- Rundeck instance

This repo should contain all of the code and components necessary to deploy the
platform from scratch.

## Components and dependency graph

There are several components in this platform which have some circular
dependencies. This means that it is neither simple nor entirely desirable to
deploy the entire platform in one go automatically, but rather factorise it into
more or less independent parts.

### Cloud envelope

The cloud envelope will differ depending on which cloud you are deploying to.
Each cloud should have its own Terraform module. The various components of the
platform will consume the data needed to create the resources they define, as a
function of this initial cloud envelope. As such, the cloud envelope should be
created first and kept for all subsequent deployments. Destroying the cloud
envelope will result in the removal of the entire platform.

### Vault

### Jenkins

### Rundeck
