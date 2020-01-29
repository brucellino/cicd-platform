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
  load_balancer {
    target_group_arn = "${aws_alb_target_group.jenkins_master_lb_tg.arn}"
    container_name = "${var.app}"
    container_port = 8080
  }
  depends_on = "${aws_lb}"
  #  depends on iam role of the instance
}

## Security groups
resource "aws_security_group" "jenkins_master" {
  name        = "${var.app}"
  description = "Jenkins master security group"
  vpc_id      = "${aws_vpc.jenkins_master.id}"

}

resource "aws_security_group" "jenkins_lb" {
  name = "${var.app}-lb-sg"
  description = "Jenkins Master ALB Security Group"
  vpc_id = "${aws_vpc.jenkins_master.id}"
}

### Security group rules
resource "aws_security_group_rule" "jenkins_master_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  cidr_blocks       = ["0.0.0.0/0"]
  protocol          = "all"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "jenkins_master_ssh" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = "${var.ssh_cidr}"
  security_group_id = "${aws_security_group.jenkins_master.id}"
}

resource "aws_security_group_rule" "lb_egress" {
  type = "egress"
  from_port = 0
  to_port = 65535
  cidr_blocks = ["0.0.0.0/0"]
  protocol = "all"
  security_group_id = "${aws_security_group.jenkins_lb.id}"
}

resource "aws_security_group_rule" "jenkins_lb_instance" {
  type = "ingress"
  from_port = 80
  to_port = 80
  security_group_id = "${aws_security_group.jenkins_lb.id}"
  source_security_group_id = "${aws_security_group.jenkins_master.id}"
  protocol = "tcp"
}

# AMI
data "aws_ami" "ecs_instance" {
  most_recent = true
  owners      = ["amazon"]

  # Find the latest ECS optimised AMI
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

## Templates
# data "template_cloudinit_config" "config" {
#   gzip = false
#   base64_encode = false
#
#   part {
#     filename =
#   }
# }

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

  # TODO - make this a var
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7BbCsbOK1ytTj49W5nKePVisX81NL8JvYcEuTTtefP4g8ysPLNTxT/LN3I986KECHoRP6d8jcUirxJNaBwEVdYHfb1cEYvLfBawQiCAedADzAp8EHaUPw5LOu6Nws3AOHIlNLrBXEc1uTx1PecJO1hQ3g/MaCsMEz6cBBRRTQ9ildXKCuZWRPl779edjbdIjBUFPlMKN7I+PmZfSCTyo1pCUmJVHJEdAaZ6zNPYxKVnqdMqMafv+1HCrvWAIVddz1XL7p3z/AM5TOrdPcHZqP9s2MqwiFRJU5O7/wAyjP6XiGojd649CyAE1NFchSOhY446/ORs+nl3HmvuVx402p"
}

## Autoscaling group

## Launch Configuration
resource "aws_launch_configuration" "ecs_jenkins" {
  name                 = "${var.app} launch configuration"
  iam_instance_profile = "${aws_iam_instance_profile.ecs_ingest.arn}"
  image_id             = "${data.aws_ami.ecs_instance.id}"
  security_groups      = ["${aws_security_group.jenkins_master.id}"]

  lifecycle {
    create_before_destroy = true
  }

  # security groups
  instance_type               = "${var.ecs_instance_type}"
  key_name                    = "${var.app}_key"
  associate_public_ip_address = true

  # user_data = "${data.template_file.user_data.rendered}"
  # depends_on = aws_efs_mount_target.jenkins_home_mount
  user_data = "${templatefile("templates/user_data.tpl", { cluster_name = "${aws_ecs_cluster.jenkins_master.name}", efs_id = "${aws_efs_file_system.jenkins_home.id}" })}"
}

## Autoscaling Group
resource "aws_autoscaling_group" "jenkins_master" {
  name     = "${aws_launch_configuration.ecs_jenkins.name}-asg"
  min_size = 1
  max_size = 2

  health_check_type    = "EC2"
  vpc_zone_identifier  = ["${aws_subnet.jenkins_master_a.id}"]
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

# ALB
resource "aws_lb" "jenkins_lb" {
  name = "${var.app}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.jenkins_lb.id}"]
  subnets = ["${aws_subnet.jenkins_master_a.id}",
  "${aws_subnet.jenkins_master_b.id}"]

  # access_logs {
  #   bucket = "${aws_s3_bucket.alb_logs.id}"
  #   prefix = "${var.app}-logs"
  #   enabled = true
  # }

  tags = {
    Name = "${var.app}"
    Environment = "test"
  }
}

resource "aws_alb_target_group" "jenkins_master_lb_tg" {
  name = "${var.app}-lb-tg"
  port = 8080
  # target_type = "ip"
  protocol = "HTTP"
  vpc_id = "${aws_vpc.jenkins_master.id}"

  depends_on = ["aws_lb.jenkins_lb"]
}

resource "aws_lb_target_group_attachment" "jenkins_master_lb_attach" {
  target_group_arn = "${aws_alb_target_group.jenkins_master_lb_tg.arn}"
  target_id = "${aws_ecs_service.jenkins_master.id}"
  port = 80
}

resource "aws_alb_listener" "jenkins_master" {
  load_balancer_arn = "${aws_lb.jenkins_lb.arn}"
  port = 80
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = "${aws_alb_target_group.jenkins_master_lb_tg.arn}"
  }
}


# Outputs

output "ami_id" {
  value = "${data.aws_ami.ecs_instance.id}"
}

output "userdata" {
  value = templatefile("../aws/templates/user_data.tpl", { cluster_name = "${aws_ecs_cluster.jenkins_master.name}", efs_id = "${aws_efs_file_system.jenkins_home.id}" })
}
