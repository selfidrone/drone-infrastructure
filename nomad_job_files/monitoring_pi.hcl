job "faas-monitoring" {
  datacenters = ["dc1"]

  type = "service"
  
  constraint {
    attribute = "${attr.cpu.arch}"
    operator  = "="
    value     = "arm"
  }
  
  constraint {
    attribute = "${attr.cpu.numcores}"
    operator  = "="
    value     = "4"
  }

  group "prometheus" {
    count = 1
    
    ephemeral_disk {
      migrate = true
      size    = "100"
      sticky  = true
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "alertmanager" {
      driver = "docker"
      
      logs {
        max_files     = 3
        max_file_size = 3
      }

			artifact {
			  source      = "https://raw.githubusercontent.com/hashicorp/faas-nomad/master/nomad_job_files/templates/alertmanager.yml"
			  destination = "local/alertmanager.yml.tpl"
				mode        = "file"
			}

      template {
        source        = "local/alertmanager.yml.tpl"
        destination   = "/etc/alertmanager/alertmanager.yml"
        change_mode   = "noop"
        change_signal = "SIGINT"
      }

      config {
        image = "alexellis2/alertmanager-armhf:0.5.1"

        port_map {
          http = 9093
        }

        dns_servers = ["${NOMAD_IP_http}", "8.8.8.8", "8.8.8.4"]

        args = [
          "-config.file=/etc/alertmanager/alertmanager.yml",
          "-storage.path=/alertmanager",
        ]

        volumes = [
          "etc/alertmanager/alertmanager.yml:/etc/alertmanager/alertmanager.yml",
        ]
      }

      resources {
        cpu    = 100 # 100 MHz
        memory = 128 # 128MB

        network {
          mbits = 1

          port "http" {}
        }
      }

      service {
        port = "http"
        name = "alertmanager"
        tags = ["faas"]
      }
    }

    task "prometheus" {
      driver = "docker"

      logs {
        max_files     = 3
        max_file_size = 3
      }

			artifact {
        source      = "https://raw.githubusercontent.com/selfidrone/drone-infrastructure/master/nomad_job_files/templates/prometheus_pi.yml"
			  destination = "local/prometheus.yml.tpl"
				mode        = "file"
			}
			
			artifact {
			  source      = "https://raw.githubusercontent.com/hashicorp/faas-nomad/master/nomad_job_files/templates/alert.rules"
			  destination = "local/alert.rules.tpl"
				mode        = "file"
			}

      template {
        source        = "local/prometheus.yml.tpl"
        destination   = "/etc/prometheus/prometheus.yml"
        change_mode   = "noop"
        change_signal = "SIGINT"
      }

      template {
        source        = "local/alert.rules.tpl"
        destination   = "/etc/prometheus/alert.rules"
        change_mode   = "noop"
        change_signal = "SIGINT"
      }

      config {
        image = "alexellis2/prometheus-armhf:1.5.2"

        args = [
          "-config.file=/etc/prometheus/prometheus.yml",
          "-storage.local.path=/prometheus",
          "-storage.local.memory-chunks=10000",
        ]

        dns_servers = ["${NOMAD_IP_http}", "8.8.8.8", "8.8.8.4"]

        port_map {
          http = 9090
        }

        volumes = [
          "etc/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml",
          "etc/prometheus/alert.rules:/etc/prometheus/alert.rules",
        ]
      }

      resources {
        cpu    = 200 # 200 MHz
        memory = 128 # 256MB

        network {
          mbits = 1

          port "http" {
            static = 9090
          }
        }
      }

      service {
        port = "http"
        name = "prometheus"
        tags = ["faas"]

        check {
          type     = "http"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
          path     = "/graph"
        }
      }
    }
  }

  group "grafana" {
    count = 1
    
    ephemeral_disk {
      migrate = true
      size    = "50"
      sticky  = true
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "grafana" {
      driver = "docker"

      logs {
        max_files     = 3
        max_file_size = 3
      }

      config {
        image = "fg2it/grafana-armhf:v4.6.2"
        volumes = ["/var/lib/grafana:/var/lib/grafana"]

        port_map {
          http = 3000
        }

        dns_servers = ["${NOMAD_IP_http}", "8.8.8.8", "8.8.8.4"]
      }

      resources {
        cpu    = 200 # 500 MHz
        memory = 256 # 256MB

        network {
          mbits = 1

          port "http" {
            static = 3000
          }
        }
      }
    }
  }
}
