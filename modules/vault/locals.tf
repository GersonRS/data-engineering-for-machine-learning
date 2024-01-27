locals {
  helm_values = [{
    vault = {
      # ui = {
      #   enabled     = true
      #   serviceType = "LoadBalancer"
      # }
      server = {
        ingress = {
          enabled = true
          annotations = {
            "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
            "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
            "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
            "traefik.ingress.kubernetes.io/router.tls"         = "true"
            "ingress.kubernetes.io/ssl-redirect"               = "true"
            "kubernetes.io/ingress.allow-http"                 = "false"
          }
          ingressClassName = "traefik"
          hosts = [
            {
              host = "vault.apps.${var.base_domain}"
            },
            {
              host = "vault.apps.${var.cluster_name}.${var.base_domain}"
            }
          ]
          tls = [{
            secretName = "vault-ingres-tls"
            hosts = [
              "vault.apps.${var.cluster_name}.${var.base_domain}"
            ]
          }]
        }
      }
    }
  }]
}
