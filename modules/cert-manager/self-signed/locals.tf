locals {
  helm_values = [{
    cert-manager = {
      installCRDs = true
      securityContext = {
        fsGroup = 999
      }
      prometheus = {
        servicemonitor = {
          enabled = var.enable_service_monitor
        }
      }
    }
    letsencrypt = {
      issuers = {
        letsencrypt-prod = {
          email  = "letsencrypt@camptocamp.com"
          server = "https://acme-v02.api.letsencrypt.org/directory"
        }
        letsencrypt-staging = {
          email  = "letsencrypt@camptocamp.com"
          server = "https://acme-staging-v02.api.letsencrypt.org/directory"
        }
      }
    }
  }]
}
