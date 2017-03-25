## IAM

resource "aws_iam_role" "ecs_service" {
  name               = "ecs_service"
  assume_role_policy = "${file("${path.module}/json/ecs-assume-role-policy.json")}"
}

resource "aws_iam_role_policy" "ecs_service" {
  name   = "ecs_policy"
  role   = "${aws_iam_role.ecs_service.name}"
  policy = "${file("${path.module}/json/ecs-service-policy.json")}"
}

resource "aws_iam_instance_profile" "app" {
  name  = "jenkins_instance"
  roles = ["${aws_iam_role.app.name}"]
}

resource "aws_iam_role" "app" {
  name               = "jenkins"
  assume_role_policy = "${file("${path.module}/json/app-assume-role-policy.json")}"
}

data "template_file" "instance_profile" {
  template = "${file("${path.module}/json/instance-profile-policy.json")}"

  vars {
    app_log_group_arn = "${aws_cloudwatch_log_group.app.arn}"
    ecs_log_group_arn = "${aws_cloudwatch_log_group.ecs.arn}"
  }
}

resource "aws_iam_role_policy" "instance" {
  name   = "jenkins_instance"
  role   = "${aws_iam_role.app.name}"
  policy = "${data.template_file.instance_profile.rendered}"
}
