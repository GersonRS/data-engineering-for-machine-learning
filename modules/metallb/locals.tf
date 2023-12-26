locals {
  helm_values = [{
    metallb = {
      crds = {
        enabled = false
      }
    }
    IPAddressPool = {
      name      = "kind-ip-addr-pool"
      namespace = var.namespace
      addresses = [
        # The following is experimental
        # TODO make sure there are enough addresses and that none of the addresses in the following range are already allocated.
        # Relates to variable refactoring proposal in variables.tf
        "${cidrhost(var.subnet, 100)}-${cidrhost(var.subnet, 250)}",
      ]
    }
    L2Advertisement = {
      name      = "kind-l2-advertisement"
      namespace = var.namespace
    }
  }]
}
