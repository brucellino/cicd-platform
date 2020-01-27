# ECS
variable "app" {
  type    = "string"
  default = "jenkins"
}

## Cluster
resource "aws_ecs_cluster" "jenkins_master" {
  name = "${var.app}"
}
