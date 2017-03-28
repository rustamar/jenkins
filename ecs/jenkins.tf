## ALB

resource "aws_alb_target_group" "jenkins" {
  name     = "jenkins"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.main.id}"

  health_check {
    path = "/login"
  }
}

resource "aws_alb" "jenkins" {
  name            = "jenkins"
  subnets         = ["${aws_subnet.main.*.id}"]
  security_groups = ["${aws_security_group.lb_sg.id}"]
}

resource "aws_alb_listener" "jenkins_front_end" {
  load_balancer_arn = "${aws_alb.jenkins.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.jenkins.id}"
    type             = "forward"
  }
}


### Compute

resource "aws_autoscaling_group" "jenkins" {
  name                 = "jenkins"
  vpc_zone_identifier  = ["${aws_subnet.main.*.id}"]
  min_size             = "${var.asg_min}"
  max_size             = "${var.asg_max}"
  desired_capacity     = "${var.asg_desired}"
  launch_configuration = "${aws_launch_configuration.jenkins.name}"
}

data "template_file" "jenkins_cloud_config" {
  template = "${file("${path.module}/cloud-config.yml")}"

  vars {
    aws_region         = "${var.aws_region}"
    ecs_cluster_name   = "${aws_ecs_cluster.jenkins.name}"
    ecs_log_level      = "info"
    ecs_agent_version  = "latest"
    ecs_log_group_name = "${aws_cloudwatch_log_group.ecs.name}"
  }
}

resource "aws_launch_configuration" "jenkins" {
  name                        = "jenkins"
  security_groups             = ["${aws_security_group.instance_sg.id}"]

  key_name                    = "${var.key_name}"
  image_id                    = "${data.aws_ami.stable_coreos.id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${aws_iam_instance_profile.app.name}"
  user_data                   = "${data.template_file.jenkins_cloud_config.rendered}"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}


## ECS

resource "aws_ecs_cluster" "jenkins" {
  name = "jenkins_ecs_cluster"
}

data "template_file" "jenkins_task_definition" {
  template = "${file("${path.module}/json/jenkins-task-definition.json")}"

  vars {
    cpu              = "256"
    image_url        = "rustamar/jenkins_generator:2"
    container_name   = "jenkins"
    container_port   = "8080"
    log_group_region = "${var.aws_region}"
    log_group_name   = "${aws_cloudwatch_log_group.app.name}"
  }
}

resource "aws_ecs_task_definition" "jenkins" {
  family                = "jenkins_task"
  container_definitions = "${data.template_file.jenkins_task_definition.rendered}"
}

resource "aws_ecs_service" "jenkins" {
  name            = "jenkins"
  cluster         = "${aws_ecs_cluster.jenkins.id}"
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
    "aws_alb_listener.jenkins_front_end",
  ]
}
