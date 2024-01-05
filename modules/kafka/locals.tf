locals {
  helm_values = [{
    kafka = {
      name            = "edh"
      version         = "3.6.1"
      versionProtocol = "3.6"
      replicas        = 1
      topic = {
        name       = "test"
        partitions = 1
        replicas   = 1
        retention  = ""
      }
    }
  }]
}
