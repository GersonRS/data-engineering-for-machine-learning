locals {
  helm_values = [{
    yamlApplicationConfig = {
      kafka = {
        clusters = [{
          name             = "local"
          bootstrapServers = "edh-ephemeral-kafka-bootstrap.ingestion.svc.cluster.local:9092"
          # schemaRegistry   = "http://cp-schema-registry:8081"
          # schemaRegistryAuth = {
          #   username = "username"
          #   password = "password"
          # }
          # metrics = {
          #   port = "9997"
          #   type = "JMX"
          # }
          #     schemaNameTemplate: "%s-value"
        }]
      }
      # spring = {
      #   security = {
      #     oauth2 = false
      #   }
      # }
      auth = {
        type = "disabled"
      }
      management = {
        health = {
          ldap = {
            enabled = false
          }
        }
      }
    }

    ingress = {
      # -- Specifies if you want to create an ingress access
      enabled : true
      # -- New style ingress class name. Only possible if you use K8s 1.18.0 or later version
      ingressClassName : "traefik"
      # -- Additional ingress annotations
      annotations = {
        "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
        "traefik.ingress.kubernetes.io/router.tls"         = "true"
        "ingress.kubernetes.io/ssl-redirect"               = "true"
        "kubernetes.io/ingress.allow-http"                 = "false"
      }
      host = "kafka-ui.apps.${var.cluster_name}.${var.base_domain}"
      # -- Ingress tls configuration for https access
      tls = {
        enabled    = true
        secretName = "kafka-ui-ingres-tls"
      }
    }
  }]
}
