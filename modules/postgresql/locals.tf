locals {
  credentials = {
    user     = "moderndevopsadmin"
    password = resource.random_password.password_secret.result
    database = "mlflow"
  }
  helm_values = [{
    volumePermissions = {
      enabled = true
    }
    global = {
      postgresql = {
        auth = {
          username       = local.credentials.user
          database       = local.credentials.database
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
      service = {
        type = "LoadBalancer"
      }
      persistence = {
        size = "10Gi"
      }
    }
  }]
}
