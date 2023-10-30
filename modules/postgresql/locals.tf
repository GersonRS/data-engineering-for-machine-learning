locals {
  credentials = {
    user     = "moderndevopsadmin"
    password = resource.random_password.password_secret.result
  }
  helm_values = [{
    volumePermissions = {
      enabled = true
    }
    global = {
      postgresql = {
        auth = {
          username       = local.credentials.user
          database       = "data"
          existingSecret = "postgres-secrets"
          secretKeys = {
            adminPasswordKey       = "postgres-password"
            userPasswordKey        = "password"
            replicationPasswordKey = "replication-password"
          }
        }
      }
    }
    image = {
      debug = true
    }
    primary = {
      initdb = {
        scripts = {
          "init.sql" = <<-EOT
            CREATE DATABASE airflow;
            CREATE DATABASE jupyterhub;
            CREATE DATABASE keycloak;
            CREATE DATABASE mlflow;
            CREATE DATABASE curated;
          EOT
        }
      }
      service = {
        type = "LoadBalancer"
      }
      persistence = {
        size = "20Gi"
      }
    }
  }]
}
