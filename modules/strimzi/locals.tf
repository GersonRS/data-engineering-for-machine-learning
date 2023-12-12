locals {
  helm_values = [{
    replicas = 1
    resources = {
      limits = {
        memory = "500Mi"
      }
    }
  }]
}
