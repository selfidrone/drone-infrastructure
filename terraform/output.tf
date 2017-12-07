
output "nomad_endpoint" {
  value = "http://${module.open-faas-nomad.nomad_alb}:4646/"
}

output "openfaas_endpoint" {
  value = "http://${module.open-faas-nomad.openfaas_alb}:8080/"
}

output "grafana_endpoint" {
  value = "http://${module.open-faas-nomad.openfaas_alb}:3000/"
}

output "prometheus_endpoint" {
  value = "http://${module.open-faas-nomad.openfaas_alb}:9090/"
}

output "s3_website_endpoint" {
  value = "${module.images_bucket.website_endpoint}"
}

output "s3_bucket_domain_name" {
  value = "${module.images_bucket.bucket_domain_name}"
}
