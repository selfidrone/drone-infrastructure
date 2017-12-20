module "nomad" {
  source = "nicholasjackson/hashicorp-suite/aws"

  namespace = "${var.namespace}"

  min_servers = "${var.min_servers}"
  max_servers = "${var.max_servers}"
  min_agents  = "${var.min_agents}"
  max_agents  = "${var.max_agents}"

  key_name = "${var.ssh_key}"

  instance_type = "${var.instance_type}"

  subnets        = ["${aws_subnet.default.*.id}"]
  vpc_id         = "${aws_vpc.default.id}"
  key_name       = "${aws_key_pair.nomad.id}"
  security_group = "${aws_security_group.allow_nomad.id}"

  client_target_groups = [
    "${aws_alb_target_group.openfaas.arn}",
    "${aws_alb_target_group.prometheus.arn}",
    "${aws_alb_target_group.grafana.arn}",
    "${aws_alb_target_group.nats.arn}",
    "${aws_alb_target_group.fabio.arn}",
  ]

  server_target_groups = ["${aws_alb_target_group.nomad.arn}"]

  consul_enabled        = true
  consul_version        = "${var.consul_version}"
  consul_join_tag_key   = "AutoJoin"
  consul_join_tag_value = "${var.namespace}"

  nomad_enabled = true
  nomad_version = "${var.nomad_version}"

  hashiui_enabled = false
  hashiui_version = ""
}

module "dns" {
  source = "./dnsimple"

  dnsimple_domain    = "demo.gs"
  dnsimple_subdomain = "drone"

  nomad_endpoint      = "${aws_alb.nomad.dns_name}"
  grafana_endpoint    = "${aws_alb.openfaas.dns_name}"
  prometheus_endpoint = "${aws_alb.openfaas.dns_name}"
  openfaas_endpoint   = "${aws_alb.openfaas.dns_name}"
  nats_endpoint       = "${aws_alb.nats.dns_name}"
  fabio_endpoint      = "${aws_alb.fabio.dns_name}"
}
