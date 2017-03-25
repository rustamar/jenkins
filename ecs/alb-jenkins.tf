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

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.jenkins.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.jenkins.id}"
    type             = "forward"
  }
}
