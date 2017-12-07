module "open-faas-nomad" {
  source = "nicholasjackson/open-faas-nomad/aws"

  namespace = "openfaas"

  instance_type = "t2.medium"

  ssh_key = "~/.ssh/id_rsa.pub"

  min_servers = "1"
  max_servers = "5"
  min_agents  = "3"
  max_agents  = "5"

  consul_version = "1.0.0"
  nomad_version  = "0.7.0"
}

module "images_bucket" {
  source = "./s3"
}

module "dns" {
  source = "./dnsimple"

  dnsimple_domain    = "demo.gs"
  dnsimple_subdomain = "drone"

  s3_website_endpoint = "${module.images_bucket.website_endpoint}"
  nomad_endpoint      = "${module.open-faas-nomad.nomad_alb}"
  grafana_endpoint    = "${module.open-faas-nomad.openfaas_alb}"
  prometheus_endpoint = "${module.open-faas-nomad.openfaas_alb}"
  openfaas_endpoint   = "${module.open-faas-nomad.openfaas_alb}"
}
