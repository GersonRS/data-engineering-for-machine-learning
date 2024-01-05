locals {
  helm_values = [{
    kafka = {
      name            = ""
      version         = ""
      versionProtocol = ""
      replicas        = ""
      topic = {
        name       = ""
        partitions = ""
        replicas   = ""
        retention  = ""
      }
    }
  }]
}
