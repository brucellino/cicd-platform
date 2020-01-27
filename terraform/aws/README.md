# AWS README

This is the README for the deployment on AWS. The required version of Terraform
for this module is >= 12.

## Resources

The module consists of the following services and resources:

- AWS VPC
  - single VPC with CIDR
  - subnets in relevant availability zones
  - Internet Gateway
  - Routing Table
  - Route to world
- IAM Roles, policies and profiles
  - IAM role
  - ECS policies
  - Instance profile for EC2 instances in the ECS cluster.
- ECS
  - Cluster
  - Task Definitions (uses JSON present in `task-definitions/` directory)
  - Service Definitions
- EFS
  - File system
  - Mount point on private subnet
  - Security Group
- EC2
  - AMI
  - Security Groups
  - Launch Configuration
    - Base ECS image filter
    - security groups
    - `cloud_init` templates for user data (uses templates in the `templates/`
      directory)
- S3
  - bucket for ALB logs

These are all kept in their respective files. Relevant variables are kept in the
`variables.tf` file.

## Modules

### VPC

- **Creates**:
  - VPC
  - subnets
  - groups
- **Data required**: none, except AWS creds.
- **Variables**:
  - `region`:
  - `admin`:
  - `app`:
  - `vpc_cidr_block`: CIDR of the private network your VPC uses
  - `vpc_cidr_block_a`, `vpc_cidr_block_b`: CIDR of the subnet allocated to AZ
    A, B

### EFS

- **Creates**:
  - EFS
  - Mount Target
  - security group rules
- **Data required**:
  - VPC
  - subnet
  - security group
