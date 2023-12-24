locals {
  issuers = {
    default = {
      name = "selfsigned-issuer"
    }
    ca = { # This value is only used when using the self-signed variant.
      name = "ca-issuer"
    }
    letsencrypt = {
      production = {
        name   = "letsencrypt-prod"
        email  = var.letsencrypt_issuer_email_main
        server = "https://acme-v02.api.letsencrypt.org/directory"
      }
      staging = {
        name   = "letsencrypt-staging"
        email  = var.letsencrypt_issuer_email_main
        server = "https://acme-staging-v02.api.letsencrypt.org/directory"
      }
    }
  }

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
    issuers = {
      default = local.issuers.default
      ca      = local.issuers.ca
      letsencrypt = { for issuer_id, issuer in local.issuers.letsencrypt :
        issuer.name => {
          email  = issuer.email
          server = issuer.server
        }
      }
    }
  }]
}
