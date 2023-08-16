locals {
  helm_values = [{
    traefik = {
      # fullnameOverride is used to set the service name in traefik data source.
      # TODO check further if setting this value is necessary.
      fullnameOverride = "traefik"
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
