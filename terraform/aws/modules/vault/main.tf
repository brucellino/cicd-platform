variable "pubkey_path" {
  type    = string
}

data "local_file" "manifest" {
  filename = "${path.module}/manifest.json"
}

data "local_file" "pubkey" {
  filename = "${var.pubkey_path}"
}

data "template_cloudinit_config" "config" {
  gzip = false
  base64_encode = false
  part {
    filename = "init.cfg"
    content_type = "text/cloud-config"
    content = "${templatefile("${path.module}/vault.hcl.tpl", { ip = aws_instance.vault.private_ip})}"
  }
}
data "aws_vpc" "vpc" {
  filter {
    name = "tag:created_by"
    values = ["Bruce.Becker"]
  }
}

data "aws_subnet" "a" {
  filter {
    name = "tag:Name"
    values = ["jenkins subnet a"]
  }
}
locals {
  content = jsondecode(data.local_file.manifest.content)
  builds = lookup(local.content, "builds")
  n = length(local.builds)
  ami_id = trimprefix(lookup(element(local.builds, local.n -1), "artifact_id"),"eu-central-1:")
}

resource "aws_key_pair" "vault_key" {
  key_name = "vault_key"
  public_key = data.local_file.pubkey.content
}

resource "aws_security_group" "ssh" {
  vpc_id = data.aws_vpc.vpc.id
  name = "ssh"
  description = "SSH Security Group"
  tags = {
    Name = "ssh security group"
  }
}

resource "aws_security_group_rule" "ssh_egress" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh.id
}

resource "aws_security_group_rule" "ssh_ingress" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ssh.id}"
}

resource "aws_s3_bucket" "vault_secrets" {
  bucket = "uefa-devops-vault-secrets"
  acl = "private"
  tags = {
    Name = "uefa-devops-vault-storage"
  }
}

resource "aws_instance" "vault" {
  ami = "${local.ami_id}"
  key_name = "${aws_key_pair.vault_key.key_name}"
  instance_type = "t2.micro"
  subnet_id = "${data.aws_subnet.a.id}"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.ssh.id}"]
  root_block_device {
    volume_type = "gp2"
    volume_size = "40"
  }
}

output "instance_ip" {
  value = aws_instance.vault.public_ip
}

output "ami_used" {
  value = local.ami_id
}
