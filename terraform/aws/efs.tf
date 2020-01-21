# EFS

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

## Mount Target
resource "aws_efs_mount_target" "jenkins_home_mount" {
  file_system_id  = "${aws_efs_file_system.jenkins_home.id}"
  subnet_id       = "${aws_subnet.jenkins_master_a.id}"
  security_groups = ["${aws_security_group.jenkins_master.id}"]
}

## Security Group
resource "aws_security_group_rule" "efs" {
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["${aws_subnet.jenkins_master_a.cidr_block}"]
  from_port         = 2049
  to_port           = 2049
  security_group_id = "${aws_security_group.jenkins_master.id}"
}
