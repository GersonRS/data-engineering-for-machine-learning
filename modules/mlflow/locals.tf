locals {
  helm_values = [{

    extraEnvVars = {
      MLFLOW_S3_ENDPOINT_URL = "http://${var.storage.endpoint}"
      MLFLOW_S3_IGNORE_TLS   = true
      # MLFLOW_S3_UPLOAD_EXTRA_ARGS: '{"ServerSideEncryption": "aws:kms", "SSEKMSKeyId": "1234"}'
      # AWS_DEFAULT_REGION: my_region
    }

    artifactRoot = {
      s3 = {
        enabled = true
        bucket = "mlflow"
        path = ""
        awsAccessKeyId = "${var.storage.access_key}"
        awsSecretAccessKey = "${var.storage.secret_access_key}"
      }
    }
    backendStore = {
      databaseConnectionCheck = true
      databaseMigration : true
      postgres = {
        enabled  = true
        host     = "${var.database.service}"
        port     = 5432
        database = "${var.database.database}"
        user     = "${var.database.user}"
        password = "${var.database.password}"
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
          host = "mlflow.apps.${var.base_domain}"
          paths = [{
            path     = "/"
            pathType = "ImplementationSpecific"
          }]
        },
        {
          host = "mlflow.apps.${var.cluster_name}.${var.base_domain}"
          paths = [{
            path     = "/"
            pathType = "ImplementationSpecific"
          }]
        }
      ]
      # -- Ingress tls configuration for https access
      tls : [{
        secretName = "mlflow-ingres-tls"
        hosts = [
          "mlflow.apps.${var.cluster_name}.${var.base_domain}"
        ]
      }]
    }
  }]
}
