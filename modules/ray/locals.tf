locals {
  helm_values = [{
    ray-cluster = {
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
      ingress = {
        # -- Specifies if you want to create an ingress access
        enabled : true
        # -- New style ingress class name. Only possible if you use K8s 1.18.0 or later version
        className : "traefik"
        # -- Additional ingress annotations
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
            paths = [{
              path     = "/"
              pathType = "ImplementationSpecific"
            }]
          },
          {
            host = "ray.apps.${var.cluster_name}.${var.base_domain}"
            paths = [{
              path     = "/"
              pathType = "ImplementationSpecific"
            }]
          }
        ]
        # -- Ingress tls configuration for https access
        tls : [{
          secretName = "ray-ingres-tls"
          hosts = [
            "ray.apps.${var.cluster_name}.${var.base_domain}"
          ]
        }]
      }
    }

  }]
}
