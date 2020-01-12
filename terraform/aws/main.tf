provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "jenkins_master" {
  cidr_block           = "192.168.1.0/24"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags {
    created_by = "Bruce"
    name       = "Jenkins VPC"
  }
}

# AWS Subnet in the VPC that Jenkins will deal with.
resource "aws_subnet" "jenkins_master" {
  availability_zone = "eu-central-1a"
  cidr_block        = "192.168.1.0/24"
  vpc_id            = "${aws_vpc.jenkins_master.id}"

  tags {
    created_by = "Bruce"
    name       = "Jenkins subnet"
  }
}

output "vpc_id" {
  value = "${aws_vpc.jenkins_master.id}"
}

output "subnets" {
  value = "${aws_subnet.jenkins_master.id}"
}
