## ECS

resource "aws_ecs_cluster" "main" {
  name = "jenkins_ecs_cluster"
}

data "template_file" "task_definition" {
  template = "${file("${path.module}/json/task-definition.json")}"

  vars {
    image_url        = "rustamar/jenkins_generator:2"
    container_name   = "jenkins"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.app.name}"
  }
}

resource "aws_ecs_task_definition" "jenkins" {
  family                = "jenkins_task"
  container_definitions = "${data.template_file.task_definition.rendered}"
}

resource "aws_ecs_service" "jenkins" {
  name            = "jenkins"
  cluster         = "${aws_ecs_cluster.main.id}"
  task_definition = "${aws_ecs_task_definition.jenkins.arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.ecs_service.name}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.jenkins.id}"
    container_name   = "jenkins"
    container_port   = "8080"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.front_end",
  ]
}
