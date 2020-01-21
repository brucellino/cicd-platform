## VPC
resource "aws_vpc" "jenkins_master" {
  cidr_block = "${var.vpc_cidr_block}"

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"

  tags = {
    created_by = "${var.admin}"
    name       = "${var.app} VPC"
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
  cidr_block        = "192.168.1.0/24"
  vpc_id            = "${aws_vpc.jenkins_master.id}"

  tags = {
    created_by = "${var.admin}"
    Name       = "${var.app} subnet a"
  }
}

resource "aws_route_table_association" "ra" {
  subnet_id      = "${aws_subnet.jenkins_master_a.id}"
  route_table_id = "${aws_route_table.rt.id}"
}
