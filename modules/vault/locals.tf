locals {
  helm_values = [{
    vault = {
      affinity = ""
      ha = {
        enabled = true
        raft = {
          enabled = true
        }
      }
    }
  }]
}
