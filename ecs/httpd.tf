## ALB

resource "aws_alb_target_group" "httpd" {
  name     = "httpd"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"
}

resource "aws_alb" "httpd" {
  name            = "httpd"
  subnets         = ["${aws_subnet.main.*.id}"]
  security_groups = ["${aws_security_group.lb_sg.id}"]
}

resource "aws_alb_listener" "httpd_front_end" {
  load_balancer_arn = "${aws_alb.httpd.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.httpd.id}"
    type             = "forward"
  }
}


### Compute

resource "aws_autoscaling_group" "httpd" {
  name                 = "httpd"
  vpc_zone_identifier  = ["${aws_subnet.main.*.id}"]
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  launch_configuration = "${aws_launch_configuration.httpd.name}"
}

data "template_file" "httpd_cloud_config" {
  template = "${file("${path.module}/cloud-config.yml")}"

  vars {
    aws_region         = "${var.aws_region}"
    ecs_cluster_name   = "${aws_ecs_cluster.httpd.name}"
    ecs_log_level      = "info"
    ecs_agent_version  = "latest"
    ecs_log_group_name = "${aws_cloudwatch_log_group.ecs.name}"
  }
}

resource "aws_launch_configuration" "httpd" {
  name                        = "httpd"
  security_groups             = [
    "${aws_security_group.instance_sg.id}",
  ]

  key_name                    = "${var.key_name}"
  image_id                    = "${data.aws_ami.stable_coreos.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.app.name}"
  user_data                   = "${data.template_file.httpd_cloud_config.rendered}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}


## ECS

resource "aws_ecs_cluster" "httpd" {
  name = "httpd_ecs_cluster"
}

data "template_file" "httpd_task_definition" {
  template = "${file("${path.module}/json/task-definition.json")}"

  vars {
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
}

resource "aws_ecs_service" "httpd" {
  name            = "httpd"
  cluster         = "${aws_ecs_cluster.httpd.id}"
  task_definition = "${aws_ecs_task_definition.httpd.arn}"
  desired_count   = 1
  iam_role        = "${aws_iam_role.ecs_service.name}"

  load_balancer {
    target_group_arn = "${aws_alb_target_group.httpd.id}"
    container_name   = "httpd"
    container_port   = "80"
  }

  depends_on = [
    "aws_iam_role_policy.ecs_service",
    "aws_alb_listener.httpd_front_end",
  ]
}
