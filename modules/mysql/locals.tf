locals {
  credentials = {
    user     = "moderngitopsadmin"
    password = resource.random_password.password_secret.result
  }
  helm_values = [{
    mysql = {
      auth = {
        database = "next"
        username = local.credentials.user
        password = local.credentials.password
      }
      # image = {
      #   debug = true
      # }
      primary = {
        # startupProbe = {
        #   enabled = false
        # }
        # livenessProbe = {
        #   enabled = false
        # }
        # readinessProbe = {
        #   enabled = false
        # }
        persistence = {
          size = "10Gi"
        }
        service = {
          type = "LoadBalancer"
        }
      }
      secondary = {
        persistence = {
          size = "10Gi"
        }
        service = {
          type = "LoadBalancer"
        }
      }
    }
  }]
}
