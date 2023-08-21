locals {
  helm_values = [{
    images = {
      airflow = {
        repository = "gersonrs/airflow"
        tag        = "v4"
      }
    }
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
    extraEnv = [
      {
        name  = "AIRFLOW_VAR_MINIO_S4"
        value = "aws:///?region_name=eu-west-1&aws_access_key_id=${var.storage.access_key}&aws_secret_access_key=${var.storage.secret_access_key}&endpoint_url=http://${var.storage.endpoint}:9000"
      },
      {
        name  = "AIRFLOW_VAR_MINIKUBE1"
        value = "kubernetes:///?__extra__=%7B%22in_cluster%22%3A+true%2C+%22disable_verify_ssl%22%3A+false%2C+%22disable_tcp_keepalive%22%3A+false%7D"
      },
      {
        name  = AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL
        value = "30"
      },
      {
        name  = AIRFLOW__WEBSERVER__BASE_URL
        value = "http//airflow.apps.${var.cluster_name}.${var.base_domain}"
      },
      {
        name  = AIRFLOW__LOGGING__REMOTE_LOGGING
        value = "True"
      },
      {
        name  = AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER
        value = "s3//airflow/logs"
      },
      {
        name  = AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID
        value = "my_aws"
      },
      {
        name  = AIRFLOW__KUBERNETES__DELETE_WORKER_PODS
        value = "True"
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
    }

    enableBuiltInSecretEnvVars = {
      AIRFLOW__CORE__FERNET_KEY = true
      AIRFLOW__CORE__SQL_ALCHEMY_CONN = true
      AIRFLOW__DATABASE__SQL_ALCHEMY_CONN = true
      AIRFLOW_CONN_AIRFLOW_DB = true
      AIRFLOW__WEBSERVER__SECRET_KEY = true
      AIRFLOW__CELERY__CELERY_RESULT_BACKEND = true
      AIRFLOW__CELERY__RESULT_BACKEND = true
      AIRFLOW__CELERY__BROKER_URL = true
      AIRFLOW__ELASTICSEARCH__HOST = true
      AIRFLOW__ELASTICSEARCH__ELASTICSEARCH_HOST = true
      AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL = true
      AIRFLOW__WEBSERVER__BASE_URL = true
      AIRFLOW__LOGGING__REMOTE_LOGGING = true
      AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER = true
      AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID = true
      AIRFLOW__KUBERNETES__DELETE_WORKER_PODS = true
      AIRFLOW_CONN_MINIO_S3 = true
      AIRFLOW_CONN_MINIKUBE = true
    }
  }]
}
