locals {
  helm_values = [{
    traefik = {
      # fullnameOverride is used to set the service name in traefik data source.
      # TODO check further if setting this value is necessary.
      fullnameOverride = "traefik"
    }
  }]
}
