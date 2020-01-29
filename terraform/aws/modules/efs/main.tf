# EFS
variable "app" {
  type    = string
  default = "jenkins"
}

variable "admin" {
  type    = string
  default = "Bruce.Becker"
}
provider "aws" {
  region = "eu-central-1"
}
## Data
data "aws_vpc" "vpc" {
  filter {
    name = "tag:Name"
    values = ["jenkins-VPC"]
  }
}

data "aws_subnet" "jenkins_master_a" {
  filter {
    name = "tag:Name"
    values = ["${var.app} subnet a"]
  }
}

data "aws_security_group" "jenkins_master" {
  filter {
    name = "tag:Name"
    values = ["${var.app}-master"]
  }
}


## File sytem
resource "aws_efs_file_system" "jenkins_home" {
  creation_token   = "jenkins_home_efs"
  encrypted        = "false"
  performance_mode = "generalPurpose"

  tags = {
    name  = "${var.app}"
    admin = "${var.admin}"
  }

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}

## Security Group
resource "aws_security_group_rule" "efs" {
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["${data.aws_subnet.jenkins_master_a.cidr_block}"]
  from_port         = 2049
  to_port           = 2049
  security_group_id = "${data.aws_security_group.jenkins_master.id}"
}
