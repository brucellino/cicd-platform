# IAM

## Role
resource "aws_iam_role" "ecs_ingest" {
  name               = "ecs_ingest"
  assume_role_policy = "${file("iam/ecs_ingest_role.json")}"
}

## policy
resource "aws_iam_role_policy" "ecs_ingest" {
  name   = "ecs_instance_role"
  role   = "${aws_iam_role.ecs_ingest.id}"
  policy = "${file("iam/ecs_ingest_policy.json")}"
}

## Instance profile
resource "aws_iam_instance_profile" "ecs_ingest" {
  name = "ingest_profile"
  role = "${aws_iam_role.ecs_ingest.name}"
}
