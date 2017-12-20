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
        image = "nats-streaming:0.6.0-linux"

        args = [
          "-store", "file", "-dir", "/tmp/nats",
          "-m", "8222",
        ]

        port_map {
          client = 4222,
          monitoring = 8222
          routing = 6222
        }
      }

      resources {
        cpu    = 400
        memory = 256

        network {
          mbits = 1

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
