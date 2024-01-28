locals {
  helm_values = [{
    strimzi-kafka-operator = {
      replicas = 1
      resources = {
        limits = {
          memory = "500Mi"
        }
      }
    }
  }]
}
