resource "dnsimple_record" "nomad" {
  domain = "${var.dnsimple_domain}"
  name   = "nomad.${var.dnsimple_subdomain}"
  value  = "${var.nomad_endpoint}"
  type   = "CNAME"
  ttl    = 360
}

resource "dnsimple_record" "grafana" {
  domain = "${var.dnsimple_domain}"
  name   = "grafana.${var.dnsimple_subdomain}"
  value  = "${var.grafana_endpoint}"
  type   = "CNAME"
  ttl    = 360
}

resource "dnsimple_record" "prometheus" {
  domain = "${var.dnsimple_domain}"
  name   = "prometheus.${var.dnsimple_subdomain}"
  value  = "${var.prometheus_endpoint}"
  type   = "CNAME"
  ttl    = 360
}

resource "dnsimple_record" "openfaas" {
  domain = "${var.dnsimple_domain}"
  name   = "openfaas.${var.dnsimple_subdomain}"
  value  = "${var.openfaas_endpoint}"
  type   = "CNAME"
  ttl    = 360
}

resource "dnsimple_record" "nats" {
  domain = "${var.dnsimple_domain}"
  name   = "nats.${var.dnsimple_subdomain}"
  value  = "${var.nats_endpoint}"
  type   = "CNAME"
  ttl    = 360
}

resource "dnsimple_record" "fabio" {
  domain = "${var.dnsimple_domain}"
  name   = "www.${var.dnsimple_subdomain}"
  value  = "${var.fabio_endpoint}"
  type   = "CNAME"
  ttl    = 360
}

variable "dnsimple_domain" {}
variable "dnsimple_subdomain" {}
variable "nomad_endpoint" {}
variable "grafana_endpoint" {}
variable "prometheus_endpoint" {}
variable "openfaas_endpoint" {}
variable "nats_endpoint" {}
variable "fabio_endpoint" {}
