locals {
  helm_values = [{
    image = {
      repository = "gersonrs/ray-ml"
      tag        = "v1"
    }

    head = {
      # containerEnv = []
      # - name: EXAMPLE_ENV
      #   value: "1"
      # envFrom = []
        # - secretRef:
        #     name: my-env-secret
      resources = {
        limits = {
          cpu    = 2
          memory = "4G"
        }
        requests = {
          cpu    = 1
          memory = "2G"
        }
      }
    }
    worker = {
      replicas = 2
      resources = {
        limits = {
          cpu    = 2
          memory = "4G"
        }
        requests = {
          cpu    = 1
          memory = "2G"
        }
      }
    }

    web = {
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
        hosts = [
          {
            host = "ray.apps.${var.base_domain}"
            path = "/"
          },
          {
            host = "ray.apps.${var.cluster_name}.${var.base_domain}"
            path = "/"
          },
        ]
        tls = [{
          secretName = "ray-tls"
          hosts = [
            "ray.apps.${var.base_domain}",
            "ray.apps.${var.cluster_name}.${var.base_domain}"
          ]
        }]
      }
    }
  }]
}
