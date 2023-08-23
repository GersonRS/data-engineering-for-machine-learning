locals {
  helm_values = [{
    # images = {
    #   airflow = {
    #     repository = "gersonrs/airflow"
    #     tag        = "v4"
    #   }
    # }
    executor                     = "KubernetesExecutor"
    webserverSecretKeySecretName = "my-webserver-secret"
    createUserJob = {
      useHelmHooks = false
    }
    migrateDatabaseJob = {
      useHelmHooks = false
    }
    ingress = {
      enabled = true
      web = {
        enabled = true
        annotations = {
          "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
          "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
          "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
          "traefik.ingress.kubernetes.io/router.tls"         = "true"
          "ingress.kubernetes.io/ssl-redirect"               = "true"
          "kubernetes.io/ingress.allow-http"                 = "false"
        }
        hosts = [{
          name = "airflow.apps.${var.cluster_name}.${var.base_domain}"
          tls = {
            enabled    = true
            secretName = "airflow-tls-ingress"
          }
        }]
        ingressClassName = "traefik"
      }
    }

    pgbouncer = {
      enabled = true
    }
    data = {
      metadataSecretName = "airflow-metadata-secret"
    }
    postgresql = {
      enabled = false
    }
    triggerer = {
      persistence = {
        size = "10Gi"
      }
    }
    logs = {
      persistence = {
        enabled          = false
        size             = "10Gi"
        storageClassName = "standard"
      }
    }
    dags = {
      gitSync = {
        enabled      = false
        repo         = "git@github.com:GersonRS/airflow-dags.git"
        branch       = "main"
        rev          = "HEAD"
        depth        = 1
        maxFailures  = 1
        subPath      = "dags"
        sshKeySecret = "airflow-ssh-secret"
        knownHosts   = "|-\n|1|yutcXh9HhbK6KCouq3xMQ38B9ns=|V9zQ39gzVxSZ75WU78CGJiVKCOk= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=\n|1|7ww9iNXn8d1jtXlaDjt+fYpsRi0=|vfHsTzw+QATWkCKD7kgG2jhu/1w= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
      }
    }
    env = [
      {
        name  = "AIRFLOW_VAR_MINIO_S4"
        value = "aws:///?region_name=eu-west-1&aws_access_key_id=${var.storage.access_key}&aws_secret_access_key=${var.storage.secret_access_key}&endpoint_url=http://${var.storage.endpoint}:9000"
      },
      {
        name  = "AIRFLOW_VAR_MINIKUBE1"
        value = "kubernetes:///?__extra__=%7B%22in_cluster%22%3A+true%2C+%22disable_verify_ssl%22%3A+false%2C+%22disable_tcp_keepalive%22%3A+false%7D"
      }
    ]

    secret = [
      {
        envName : "AIRFLOW_CONN_MINIO_S3"
        secretName : "minio-s3-airflow-connections"
        secretKey : "AIRFLOW_CONN_MINIO_S3"
      },
      {
        envName : "AIRFLOW_CONN_MINIKUBE"
        secretName : "minikube-airflow-connections"
        secretKey : "AIRFLOW_CONN_MINIKUBE"
      },

    ]

    extraSecrets = {
      airflow-metadata-secret = {
        data = "connection: ${base64encode("postgresql://${var.database.user}:${var.database.password}@${var.database.service}:5432/${var.database.database}")}"
      }
      my-webserver-secret = {
        data = "webserver-secret-key: ${base64encode(resource.random_password.airflow_webserver_secret_key.result)}"
      }
      minio-s3-airflow-connections = {
        data = "AIRFLOW_CONN_MINIO_S3: ${base64encode("aws:///?region_name=eu-west-1&aws_access_key_id=${var.storage.access_key}&aws_secret_access_key=${var.storage.secret_access_key}&endpoint_url=http://${var.storage.endpoint}:9000")}"
      }
      minikube-airflow-connections = {
        data = "AIRFLOW_CONN_MINIKUBE: ${base64encode("kubernetes:///?__extra__=%7B%22in_cluster%22%3A+true%2C+%22disable_verify_ssl%22%3A+false%2C+%22disable_tcp_keepalive%22%3A+false%7D")}"
      }
      airflow-airflow-connections = {
        data = <<-EOT
          AIRFLOW_CONN_MINIKUBE2: ${base64encode("kubernetes:///?__extra__=%7B%22in_cluster%22%3A+true%2C+%22disable_verify_ssl%22%3A+false%2C+%22disable_tcp_keepalive%22%3A+false%7D")}
          AIRFLOW_CONN_AWS: ${base64encode("aws:///?region_name=eu-west-1&aws_access_key_id=${var.storage.access_key}&aws_secret_access_key=${var.storage.secret_access_key}&endpoint_url=http://${var.storage.endpoint}:9000")}
        EOT
      }
    }

    extraEnv = <<-EOT
      - name: AIRFLOW_VAR_MINIO_S5
        value: "aws:///?region_name=eu-west-1&aws_access_key_id=${var.storage.access_key}&aws_secret_access_key=${var.storage.secret_access_key}&endpoint_url=http://${var.storage.endpoint}:9000"
    EOT

    extraConfigMaps = {
      airflow-airflow-variables = {
        data = <<-EOT
          AIRFLOW_VAR_HELLO_MESSAGE: 'Hi!'
          AIRFLOW_VAR_KUBERNETES_NAMESPACE: '{{ .Release.Namespace }}'
        EOT
      }
    }

    extraEnvFrom = <<-EOT
      - configMapRef:
          name: 'airflow-airflow-variables'
      - secretRef:
          name: 'airflow-airflow-connections'
    EOT
  }]
}
