# Create a new load balancer
resource "aws_alb" "nomad" {
  name            = "${var.namespace}-nomad"
  internal        = false
  security_groups = ["${aws_security_group.allow_nomad.id}"]
  subnets         = ["${aws_subnet.default.*.id}"]
}

resource "aws_alb_target_group" "nomad" {
  name     = "${var.namespace}-nomad"
  port     = 4646
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    path    = "/v1/status/leader"
    matcher = "200,202"
  }
}

resource "aws_alb_listener" "nomad" {
  load_balancer_arn = "${aws_alb.nomad.arn}"
  port              = "4646"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.nomad.arn}"
    type             = "forward"
  }
}

resource "aws_alb" "openfaas" {
  name            = "${var.namespace}-openfaas"
  internal        = false
  security_groups = ["${aws_security_group.allow_nomad.id}"]
  subnets         = ["${aws_subnet.default.*.id}"]
}

resource "aws_alb_target_group" "openfaas" {
  name     = "${var.namespace}-openfaas"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    path    = "/ui/"
    matcher = "200,202"
  }
}

resource "aws_alb_listener" "openfaas" {
  load_balancer_arn = "${aws_alb.openfaas.arn}"
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.openfaas.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "prometheus" {
  name     = "${var.namespace}-prometheus"
  port     = 9090
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    path    = "/graph"
    matcher = "200,202"
  }
}

resource "aws_alb_listener" "prometheus" {
  load_balancer_arn = "${aws_alb.openfaas.arn}"
  port              = "9090"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.prometheus.arn}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "grafana" {
  name     = "${var.namespace}-grafana"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    path    = "/login"
    matcher = "200,202"
  }
}

resource "aws_alb_listener" "grafana" {
  load_balancer_arn = "${aws_alb.openfaas.arn}"
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.grafana.arn}"
    type             = "forward"
  }
}

resource "aws_alb" "nats" {
  name               = "${var.namespace}-nats"
  internal           = false
  subnets            = ["${aws_subnet.default.*.id}"]
  load_balancer_type = "network"
}

resource "aws_alb_target_group" "nats" {
  name     = "${var.namespace}-nats"
  port     = 4222
  protocol = "TCP"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    protocol = "HTTP"
    path     = "/connz"
    matcher  = "200-399"
    port     = 8222
    timeout  = 6
  }
}

resource "aws_alb_listener" "nats" {
  load_balancer_arn = "${aws_alb.nats.arn}"
  port              = "4222"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_alb_target_group.nats.arn}"
    type             = "forward"
  }
}

resource "aws_alb" "fabio" {
  name            = "${var.namespace}-fabio"
  internal        = false
  security_groups = ["${aws_security_group.allow_nomad.id}"]
  subnets         = ["${aws_subnet.default.*.id}"]
}

resource "aws_alb_target_group" "fabio" {
  name     = "${var.namespace}-fabio"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.default.id}"

  health_check {
    path    = "/health"
    matcher = "200,202"
  }
}

resource "aws_alb_listener" "fabio" {
  load_balancer_arn = "${aws_alb.fabio.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.fabio.arn}"
    type             = "forward"
  }
}
