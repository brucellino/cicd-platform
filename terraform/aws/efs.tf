resource "aws_efs_file_system" "jenkins_home" {
  creation_token   = "jenkins_home_efs"
  encrypted        = "false"
  performance_mode = "generalPurpose"

  tags {
    name = "jenkins"
  }

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}

resource "aws_efs_mount_target" "jenkins_home_mount" {
  file_system_id = "${aws_efs_file_system.jenkins_home.id}"
  subnet_id      = "${aws_subnet.jenkins_master.id}"
}

output "efs_dns" {
  value = "${aws_efs_file_system.jenkins_home.dns_name}"
}

output "efs_id" {
  value = "${aws_efs_file_system.jenkins_home.id}"
}
