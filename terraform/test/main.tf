# Variables

variable "app" {
  type = "string"
  default = "jenkins_master"
}

variable "jenkins_plugins" {
  type    = "list"
  default = [
    "pipeline-githubnotify-step",
    "plain-credentials",
    "workflow-job",
    "pipeline-model-api",
    "blueocean-pipeline-editor",
    "performance",
    "blueocean-bitbucket-pipeline",
    "handlebars",
    "blueocean-jwt",
    "antisamy-markup-formatter",
    "cloudbees-folder",
    "workflow-step-api",
    "pipeline-model-extensions",
    "github-oauth",
    "aws-credentials",
    "github-branch-source",
    "ssh-credentials",
    "docker-java-api",
    "blueocean-core-js",
    "jquery-detached",
    "docker-plugin",
    "aws-java-sdk",
    "pipeline-model-declarative-agent",
    "blueocean-config",
    "pipeline-github",
    "blueocean-personalization",
    "ace-editor",
    "blueocean-display-url",
    "cloudbees-bitbucket-branch-source",
    "workflow-cps",
    "github-pullrequest",
    "jenkins-design-language",
    "git-client",
    "scm-api",
    "mailer",
    "pipeline-stage-view",
    "blueocean-jira",
    "blueocean-pipeline-scm-api",
    "pipeline-graph-analysis",
    "blueocean-i18n",
    "matrix-auth",
    "pipeline-stage-step",
    "structs",
    "pipeline-input-step",
    "ssh-slaves",
    "pipeline-maven",
    "workflow-aggregator",
    "jsch",
    "blueocean-executor-info",
    "configuration-as-code-support",
    "display-url-api",
    "pipeline-github-lib",
    "blueocean-events",
    "gradle",
    "blueocean-pipeline-api-impl",
    "blueocean-git-pipeline",
    "ec2",
    "sse-gateway",
    "pipeline-build-step",
    "apache-httpcomponents-client-4-api",
    "durable-task",
    "blueocean-rest",
    "jira",
    "slack",
    "junit",
    "workflow-cps-global-lib",
    "job-dsl",
    "amazon-ecr",
    "node-iterator-api",
    "amazon-ecs",
    "git-server",
    "sonar",
    "matrix-project",
    "mercurial",
    "workflow-durable-task-step",
    "docker-workflow",
    "variant",
    "credentials",
    "pipeline-model-definition",
    "configuration-as-code",
    "blueocean-autofavorite",
    "script-security",
    "pubsub-light",
    "workflow-api",
    "config-file-provider",
    "blueocean-rest-impl",
    "blueocean-github-pipeline",
    "lockable-resources",
    "workflow-multibranch",
    "htmlpublisher",
    "workflow-basic-steps",
    "workflow-scm-step",
    "token-macro",
    "github",
    "momentjs",
    "docker-commons",
    "workflow-support",
    "authentication-tokens",
    "icon-shim",
    "jackson2-api",
    "github-issues",
    "pipeline-milestone-step",
    "github-api",
    "git",
    "blueocean-commons",
    "favorite",
    "bouncycastle-api",
    "blueocean-web",
    "pipeline-stage-tags-metadata",
    "pipeline-rest-api",
    "branch-api",
    "handy-uri-templates-2-api",
    "blueocean-dashboard",
    "credentials-binding",
    "blueocean",
    "gitlab-plugin",
    "hashicorp-vault-plugin",
    "hashicorp-vault-pipeline",
    "pipeline-utility-steps",
    "pipeline-aws"
  ]
}
variable "admin" {
  type    = "string"
  default = "Bruce"
}

variable "region" {
  type = "string"
  default = "eu-central-1"
}

variable "vpc_cidr_block" {
  type    = "string"
  default = "192.168.1.0/24"
}

variable "ecs_instance_type" {
  type    = "string"
  default = "c3.large"
}

variable "ssh_cidr" {
  type    = "list"
  default = ["2.45.231.44/32"]
}
# cloud
provider "aws" {
  region = "${var.region}"
}

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

# data "aws_route_table" "rt" {
#   subnet_id = "${aws_subnet.jenkins_master_a.id}"
# }
#
# resource "aws_route" "r" {
#   route_table_id = "${data.aws_route_table.rt.id}"
#   destination_cidr_block = "0.0.0.0/0"
# }
## subnet
#-- If you subnets in other availability zones, add them after this,
#-- with different CIDR
resource "aws_subnet" "jenkins_master_a" {
  availability_zone = "eu-central-1a"
  cidr_block        = "192.168.1.0/24"
  vpc_id            = "${aws_vpc.jenkins_master.id}"

  tags = {
    created_by = "${var.admin}"
    name       = "${var.app} subnet a"
  }
}

## Security groups
resource "aws_security_group" "jenkins_master" {
  name = "${var.app}"
  description = "Jenkins master security group"
  vpc_id = "${aws_vpc.jenkins_master.id}"
}

### Security group rules
resource "aws_security_group_rule" "jenkins_master_egress" {
  type = "egress"
  from_port = 0
  to_port = 65535
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "all"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ssh" {
  type = "ingress"
  protocol = "tcp"
  from_port = 22
  to_port = 22
  cidr_blocks = "${var.ssh_cidr}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "efs" {
  type = "ingress"
  protocol = "tcp"
  cidr_blocks = ["${aws_subnet.jenkins_master_a.cidr_block}"]
  from_port = 2049
  to_port = 2049
  security_group_id = "${aws_security_group.jenkins_master.id}"
}
# IAM

## Role
resource "aws_iam_role" "ecs_ingest" {
  name               = "ecs_ingest"
  assume_role_policy = "${file("../aws/iam/ecs_ingest_role.json")}"
}

## policy
resource "aws_iam_role_policy" "ecs_ingest" {
  name   = "ecs_instance_role"
  role   = "${aws_iam_role.ecs_ingest.id}"
  policy = "${file("../aws/iam/ecs_ingest_policy.json")}"
}

## Instance profile
resource "aws_iam_instance_profile" "ecs_ingest" {
  name = "ingest_profile"
  role = "${aws_iam_role.ecs_ingest.name}"
}

# EFS

## File sytem
resource "aws_efs_file_system" "jenkins_home" {
  creation_token   = "jenkins_home_efs"
  encrypted        = "false"
  performance_mode = "generalPurpose"

  tags = {
    name = "${var.app}"
    admin = "${var.admin}"
  }

  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }
}

## Mount Target
resource "aws_efs_mount_target" "jenkins_home_mount" {
  file_system_id = "${aws_efs_file_system.jenkins_home.id}"
  subnet_id      = "${aws_subnet.jenkins_master_a.id}"
  security_groups = ["${aws_security_group.jenkins_master.id}"]
}

# AMI
data "aws_ami" "ecs_instance" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
}

## Templates
# data "template_file" "user_data" {
#   template = "../aws/templates/user_data.tpl"
#   vars = {
#     cluster = "{aws_ecs_cluster.jenkins_master.id}"
#     efs_id = "${aws_efs_file_system.jenkins_home.id}"
#   }
# }



# EC2
resource "aws_key_pair" "admin" {
  key_name = "${var.app}_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7BbCsbOK1ytTj49W5nKePVisX81NL8JvYcEuTTtefP4g8ysPLNTxT/LN3I986KECHoRP6d8jcUirxJNaBwEVdYHfb1cEYvLfBawQiCAedADzAp8EHaUPw5LOu6Nws3AOHIlNLrBXEc1uTx1PecJO1hQ3g/MaCsMEz6cBBRRTQ9ildXKCuZWRPl779edjbdIjBUFPlMKN7I+PmZfSCTyo1pCUmJVHJEdAaZ6zNPYxKVnqdMqMafv+1HCrvWAIVddz1XL7p3z/AM5TOrdPcHZqP9s2MqwiFRJU5O7/wAyjP6XiGojd649CyAE1NFchSOhY446/ORs+nl3HmvuVx402p"
}

## Autoscaling group

## Launch Configuration
resource "aws_launch_configuration" "ecs_jenkins" {
  name = "${var.app} launch configuration"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_ingest.arn}"
  image_id = "${data.aws_ami.ecs_instance.id}"
  security_groups = ["${aws_security_group.jenkins_master.id}"]
  lifecycle {
    create_before_destroy = true
  }

  # security groups
  instance_type = "${var.ecs_instance_type}"
  key_name = "${var.app}_key"
  associate_public_ip_address = true

  # user_data = "${data.template_file.user_data.rendered}"
  # depends_on = aws_efs_mount_target.jenkins_home_mount
  user_data = "${templatefile("../aws/templates/user_data.tpl", { cluster_name = "${aws_ecs_cluster.jenkins_master.name}", efs_id = "${aws_efs_file_system.jenkins_home.id}" } )}"
}

## Autoscaling Group
resource "aws_autoscaling_group" "jenkins_master" {
  name = "${aws_launch_configuration.ecs_jenkins.name}-asg"
  min_size = 1
  max_size = 2

  health_check_type = "EC2"
  vpc_zone_identifier = ["${aws_subnet.jenkins_master_a.id}"]
  launch_configuration = "${aws_launch_configuration.ecs_jenkins.name}"
}

## Autoscaling Policy (up)
resource "aws_autoscaling_policy" "cpu_hot_policy" {
  name                   = "cpu-hot-policy"
  autoscaling_group_name = "${aws_autoscaling_group.jenkins_master.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "1"
  # cooldown: no utilization can happen!!!
  cooldown    = "300"
  policy_type = "SimpleScaling"
}

## Autoscaling Policy (down)
resource "aws_autoscaling_policy" "cpu_cold_policy" {
  name                   = "cpu-cold-policy"
  autoscaling_group_name = "${aws_autoscaling_group.jenkins_master.name}"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = "-1"
  # cooldown: no utilization can happen!!!
  cooldown    = "300"
  policy_type = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "reservation_alarm" {
  alarm_name          = "cpu-reservations"
  alarm_description   = "CPU reservations full"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "20"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.jenkins_master.name}"
  }
  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.cpu_hot_policy.arn}"]
}


## CloudWatch Metric Alarm (hot)
resource "aws_cloudwatch_metric_alarm" "cpu_hot_alarm" {
  alarm_name          = "cpu-hot-alarm"
  alarm_description   = "CPU Utilisation above threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "90"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.jenkins_master.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.cpu_hot_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "cpu_cold_alarm" {
  alarm_name          = "cpu-cold-alarm"
  alarm_description   = "Scale down due to low CPU utilisation"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "20"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.jenkins_master.name}"
  }

  actions_enabled = true
  alarm_actions   = ["${aws_autoscaling_policy.cpu_cold_policy.arn}"]
}


## CloudWatch Metric Alarm (under)

# ECS

## Cluster
resource "aws_ecs_cluster" "jenkins_master" {
  name = "${var.app}"
}

## Task Defintion

## Service


# Outputs

output "ami_id" {
  value = "${data.aws_ami.ecs_instance.id}"
}

output "userdata" {
  value = templatefile("../aws/templates/user_data.tpl", { cluster_name = "${aws_ecs_cluster.jenkins_master.name}", efs_id = "${aws_efs_file_system.jenkins_home.id}" } )
}
