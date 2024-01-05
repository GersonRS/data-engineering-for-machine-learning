locals {
  helm_values = [{
    kafka = {
      name            = "edh"
      version         = "3.6.0"
      versionProtocol = "3.6"
      replicas        = 3
      topic = {
        name       = "test"
        partitions = 1
        replicas   = 3
        retention  = 7200000
      }
    }
  }]
}
