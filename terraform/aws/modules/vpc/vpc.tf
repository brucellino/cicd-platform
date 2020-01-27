# cloud
provider "aws" {
  region = "${var.region}"
}

data "aws_billing_service_account" "main" {}

# Variables
variable "region" {
  type    = "string"
  default = "eu-central-1"
}
variable "admin" {
  type    = "string"
  default = "Bruce.Becker"
}

variable "app" {
  type    = "string"
  default = "jenkins"
}

variable "vpc_cidr_block" {
  type = "string"
  default = "192.168.1.0/24"
}

variable "vpc_cidr_block_a" {
  type    = "string"
  default = "192.168.1.0/25"
}

variable "vpc_cidr_block_b" {
  type    = "string"
  default = "192.168.1.128/25"
}

# VPC
resource "aws_vpc" "jenkins_master" {
  cidr_block = "${var.vpc_cidr_block}"

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    created_by = "${var.admin}"
    Name       = "${var.app}-VPC"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.jenkins_master.id}"
}

resource "aws_route_table" "rt" {
  # subnet_id = "${aws_subnet.jenkins_master_a.id}"
  vpc_id = "${aws_vpc.jenkins_master.id}"
  tags = {
    Name        = "jenkins route table"
    description = "Route table for the Jenkins deployment"
  }
}

resource "aws_route" "r" {
  route_table_id         = "${aws_route_table.rt.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

## subnet
#-- If you subnets in other availability zones, add them after this,
#-- with different CIDR
resource "aws_subnet" "jenkins_master_a" {
  availability_zone = "eu-central-1a"
  cidr_block        = "${var.vpc_cidr_block_a}"
  vpc_id            = "${aws_vpc.jenkins_master.id}"

  tags = {
    created_by = "${var.admin}"
    Name       = "${var.app} subnet a"
  }
}

resource "aws_subnet" "jenkins_master_b" {
  availability_zone = "eu-central-1b"
  cidr_block = "${var.vpc_cidr_block_b}"
  vpc_id = "${aws_vpc.jenkins_master.id}"

  tags = {
    created_by = "${var.admin}"
    Name       = "${var.app} subnet b"
  }
}

resource "aws_route_table_association" "ra" {
  subnet_id      = "${aws_subnet.jenkins_master_a.id}"
  route_table_id = "${aws_route_table.rt.id}"
}


# security groups
resource "aws_security_group" "jenkins_master" {
  name = "${var.app}-master"
  description = "Jenkins master security group"
  vpc_id      = "${aws_vpc.jenkins_master.id}"
  tags = {
    Name = "${var.app}-master"
  }
}
