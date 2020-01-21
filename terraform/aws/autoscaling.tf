# resource "aws_launch_configuration" "ecs_cluster" {
#   name = "Jenkins master cluster AutoScaling Group"
#   iam_instance_profile = "${aws_iam_instance_profile.ingest.id}"
#   enable_monitoring = true
#   image_id = "${var.jenkins_master_image_id}"
#   instance_type = "${var.jenkins_master_ecs_instance_type}"
#
#   lifecycle = {
#     create_before_destroy = true
#   }
#
#   # security_groups = [""]
#   associate_public_ip_address = true
#   key_name = "jenkins_key"
#
#   iam_instance_profile = "${aws_iam_instance_profile.ecs_ingest.name}"
# }
#
# resource "aws_autoscaling_group" "jenkins_master" {
#   name = "${aws_launch_configuration.ecs_cluster.name}-asg"
#   min_size = 1
#
#   max_size = 3
#
#   health_check_type = "EC2"
#
#   vpc_zone_identifier = ["${aws_subnet.jenkins_master.id}"]
#   launch_configuration = "${aws_launch_configuration.ecs_cluster.name}"
# }

