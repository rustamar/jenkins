

## ECS

data "template_file" "httpd_task_definition" {
  template = "${file("${path.module}/json/httpd-task-definition.json")}"

  vars {
    cpu              = "256"
    image_url        = "httpd:2.4"
    container_name   = "httpd"
    container_port   = "80"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.app.name}"
  }
}

resource "aws_ecs_task_definition" "httpd" {
  family                = "httpd_task"
  container_definitions = "${data.template_file.httpd_task_definition.rendered}"
  volume {
    name      = "http_storage"
    host_path = "/var/httpd"
  }
}

resource "aws_ecs_service" "httpd" {
  name            = "httpd"
  cluster         = "${aws_ecs_cluster.jenkins.id}"
  task_definition = "${aws_ecs_task_definition.httpd.arn}"
  desired_count   = 1
}
