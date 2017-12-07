/*
resource "aws_alb" "nats" {
  name            = "${var.namespace}-nats"
  internal        = false
  security_groups = ["${module.open-faas-nomad.security_group}"]
  subnets         = ["${module.open-faas-nomad.subnets}"]
}

resource "aws_alb_target_group" "nats-monitoring" {
  name     = "${var.namespace}-nats"
  port     = 6222
  protocol = "HTTP"
  vpc_id   = ""

  health_check {
    path    = "/connz"
    matcher = "200,202"
  }
}

resource "aws_alb_listener" "nats-monitoring" {
  load_balancer_arn = "${aws_alb.nomad.arn}"
  port              = "6222"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.nats.arn}"
    type             = "forward"
  }
}
*/

