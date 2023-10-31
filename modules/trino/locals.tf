locals {
  helm_values = [{
    coordinator = {
      jvm = {
        maxHeapSize = "3G"
      }
    }
    server = {
      workers = 2
      config = {
        query = {
          maxMemory             = "2GB"
          maxMemoryPerNode      = "2GB"
          maxTotalMemory        = "3GB"
          maxTotalMemoryPerNode = "2GB"
        }
      }
    }
    ingress = {
      enabled   = true
      className = "traefik"
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
          host = "trino.apps.${var.base_domain}"
          paths = [{
            path     = "/"
            pathType = "ImplementationSpecific"
          }]
        },
        {
          host = "trino.apps.${var.cluster_name}.${var.base_domain}"
          paths = [{
            path     = "/"
            pathType = "ImplementationSpecific"
          }]
        }
      ]
      # -- Ingress tls configuration for https access
      tls = [{
        secretName = "trino-ingres-tls"
        hosts = [
          "trino.apps.${var.cluster_name}.${var.base_domain}"
        ]
      }]
    }

    additionalCatalogs = {
      pinot.properties = <<-EOT
        connector.name=pinot
        pinot.controller-urls=${var.pinot_dns}
      EOT

      # kafka.properties: |-
      # connector.name=kafka
      # kafka.table-names=src-app-users-json,src-app-agent-json,src-app-credit-card-json,src-app-musics-json,src-app-rides-json
      # kafka.nodes=edh-kafka-brokers.ingestion.svc.Cluster.local:9092
      # kafka.hide-internal-columns=false

      minio.properties = <<-EOT
        connector.name=hive-hadoop2
        hive.metastore=file
        hive.s3-file-system-type=TRINO
        hive.metastore.catalog.dir=s3://${var.storage.bucket_name}/
        hive.allow-drop-table=true
        hive.s3.aws-access-key=${var.storage.access_key}
        hive.s3.aws-secret-key=${var.storage.secret_access_key}
        hive.s3.endpoint=http://${var.storage.endpoint}
        hive.s3.path-style-access=true
        hive.s3.ssl.enabled=false
        hive.s3select-pushdown.enabled=true
        hive.allow-add-column=true
        hive.allow-drop-column=true
        hive.allow-drop-table=true
        hive.allow-rename-table=true
        hive.allow-rename-column=true
        hive.s3.multipart.min-file-size=5GB
        hive.s3.multipart.min-part-size=5GB
        hive.s3.max-connections=5000
      EOT

      postgres.properties = <<-EOT
        connector.name=postgresql
        connection-url=jdbc:postgresql://${var.database.service}:5432/${var.database.database}
        connection-user=${var.database.user}
        connection-password=${var.database.password}
      EOT
    }
  }]
}
