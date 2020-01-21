# ECS

## Cluster
resource "aws_ecs_cluster" "jenkins_master" {
  name = "${var.app}"
}

## Task Defintion
resource "aws_ecs_task_definition" "jenkins_master" {
  family                = "jenkins_master"
  container_definitions = "${file("../aws/task-definitions/jenkins-master.json")}"

  volume {
    name      = "jenkins_master_home"
    host_path = "/mnt/efs/jenkins_home"
  }
}

## Service
resource "aws_ecs_service" "jenkins_master" {
  name            = "jenkins_master"
  cluster         = "${aws_ecs_cluster.jenkins_master.id}"
  task_definition = "${aws_ecs_task_definition.jenkins_master.arn}"
  desired_count   = 1
}

# Outputs

output "ami_id" {
  value = "${data.aws_ami.ecs_instance.id}"
}

output "userdata" {
  value = templatefile("../aws/templates/user_data.tpl", { cluster_name = "${aws_ecs_cluster.jenkins_master.name}", efs_id = "${aws_efs_file_system.jenkins_home.id}" })
}
