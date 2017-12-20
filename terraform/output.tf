output "nomad_alb" {
  value = "${aws_alb.nomad.dns_name}"
}

output "nats_alb" {
  value = "${aws_alb.nats.dns_name}"
}

output "fabio_alb" {
  value = "${aws_alb.fabio.dns_name}"
}

output "openfaas_alb" {
  value = "${aws_alb.openfaas.dns_name}"
}

output "vpc_id" {
  value = "${aws_vpc.default.id}"
}

output "security_group" {
  value = "${aws_security_group.allow_nomad.id}"
}

output "route_table_id" {
  value = "${aws_vpc.default.main_route_table_id}"
}

output "subnets" {
  value = ["${aws_subnet.default.*.id}"]
}
