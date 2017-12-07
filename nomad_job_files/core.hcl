job "drone-core" {
  datacenters = ["dc1"]

  type = "service"

  constraint {
    attribute = "${attr.cpu.arch}"
    operator  = "!="
    value     = "arm"
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

        args = ["-store", "file", "-dir", "/tmp/nats"]

        port_map {
          client = 4222,
          monitoring = 8222
          routing = 6222
        }
      }

      resources {
        cpu    = 400 # 100 MHz
        memory = 512 # 128MB

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
        tags = ["faas"]

        check {
           type     = "http"
           port     = "monitoring"
           path     = "/connz"
           interval = "5s"
           timeout  = "2s"
        }
      }
    }
    
    task "nats-faas" {
      driver = "docker"

      template {
        destination   = "/etc/config/config.yml"
        change_mode   = "noop"
        change_signal = "SIGINT"

        # Our template contains go template in the code so to avoid this being parsed by Nomad we need to change the 
        # delimiters it is using
        left_delimiter = "(("
        right_delimiter = "))"

        data = <<EOH
nats: nats://(( env "NOMAD_IP_health" )):4222
nats_cluster_id: test-cluster
gateway: http://(( env "NOMAD_IP_health" )):8080
statsd: (( env "NOMAD_IP_health" )):9125
log_level: INFO
log_format: text
functions:
  - name: echo
    function_name: echo
    message: example.echo
    success_message: example.info.success
    templates:
      input_template: |
        {
          "subject": "{{ .JSON.subject }}"
        }
      output_template: |
          {{printf "%s" .Raw}}
  - name: tweet
    function_name: tweet
    message: picture.new
    templates:
      input_template: |
        {
          "text": "Hey a picture from selfi drone",
          "image": "{{ .JSON.Data }}"
        }
  - name: facedetect
    function_name: facedetect
    message: image.stream
    success_message: image.facedetection
    templates:
      input_template: |
        {{ .JSON.Data }}
      output_template: |
        {{printf "%s" .Raw}}

  - name: liveimageprocess
    function_name: facedetect
    query_string: output=image
    message: image.stream
    success_message: image.live
    templates:
      input_template: |
        {{ .JSON.Data }}
      output_template: |
        {
          "Data": "{{base64encode .Raw}}"
        }
EOH
      }

      config {
        image = "quay.io/nicholasjackson/faas-nats:0.4.10"
        args = ["-config","/etc/config/config.yml"]

        port_map {
          health = 9999
        }
        
        volumes = [
          "etc/config/config.yml:/etc/config/config.yml"
        ]
      }

      resources {
        cpu    = 200 # 100 MHz
        memory = 128 # 128MB

        network {
          mbits = 10

          port "health" {}
        }
      }

      service {
        name = "nats-faas"
        tags = ["faas"]
        port = "health"

        check {
           type     = "http"
           port     = "health"
           path     = "/health"
           interval = "5s"
           timeout  = "2s"
        }
      }
    }

    task "preview" {
      driver = "docker"

      config {
        image = "nicholasjackson/drone-live:0.5"
        args = [
          "-nats","nats://${NOMAD_IP_http}:4222",
          "-source","/home/dronelive/"
        ]

        port_map {
          http = 4000,
        }
      }

      resources {
        cpu    = 200 # 100 MHz
        memory = 128 # 128MB

        network {
          mbits = 10

          port "http" {}
        }
      }

      service {
        port = "http"
        name = "preview"
        tags = ["faas"]

        tags = [
          "urlprefix-/",
        ]

        check {
           type     = "http"
           port     = "http"
           path     = "/health"
           interval = "5s"
           timeout  = "2s"
        }
      }
    }
  }
}
