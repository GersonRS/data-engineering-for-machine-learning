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
  }]
}
