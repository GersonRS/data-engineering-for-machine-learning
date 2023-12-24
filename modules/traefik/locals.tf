locals {
  helm_values = [{
    traefik = {
      deployment = {
        replicas = var.replicas
      }
      metrics = {
        prometheus = {
          service = {
            enabled = true
          }
          serviceMonitor = var.enable_service_monitor ? {
            # dummy attribute to make serviceMonitor evaluate to true in a condition in the helm chart
            foo = "bar"
          } : {}
        }
      }
      additionalArguments = [
        "--serversTransport.insecureSkipVerify=true"
      ]
      logs = {
        access = {
          enabled = true
        }
      }
      tlsOptions = {
        default = {
          minVersion = "VersionTLS12"
        }
      }
      ports = var.enable_https_redirection ? {
        web = {
          redirectTo = {
            port = "websecure"
          }
        }
      } : null
      ressources = {
        limits = {
          cpu    = "250m"
          memory = "512Mi"
        }
        requests = {
          cpu    = "125m"
          memory = "256Mi"
        }
      }
      middlewares = {
        redirections = {
          withclustername = {
            permanent   = false
            regex       = "apps.${var.base_domain}"
            replacement = "apps.${var.cluster_name}.${var.base_domain}"
          }
        }
      }
    }
  }]
}
