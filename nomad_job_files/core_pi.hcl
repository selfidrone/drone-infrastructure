job "drone-core" {
  datacenters = ["dc1"]

  type = "service"

  constraint {
    attribute = "${attr.cpu.arch}"
    operator  = "="
    value     = "arm"
  }

  constraint {
    attribute = "${attr.cpu.numcores}"
    operator = "="
    value = "4"
  }

  group "core" {
    count = 1

    restart {
      attempts = 10
      interval = "5m"
      delay    = "25s"
      mode     = "delay"
    }

    task "nats" {
      driver = "docker"

      config {
        image = "nats:1.0.4-linux"

        port_map {
          client = 4222,
          monitoring = 8222
          routing = 6222
        }
      }

      resources {
        cpu    = 200 # 100 MHz

        network {
          mbits = 10

          port "client" {
            static = 4222 
          }

          port "monitoring" {
            static = 6222 
          }

          port "routing" {
            static = 8222 
          }
        }
      }

      service {
        port = "client"
        name = "nats"
        tags = ["pi"]

        check {
           type     = "http"
           port     = "monitoring"
           path     = "/connz"
           interval = "5s"
           timeout  = "2s"
        }
      }
    }
  }
}
