output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "cluster_issuers" {
  description = "List of cluster issuers created by cert-manager."
  value = merge({
    default = local.issuers.default.name
    }, {
    for issuer_id, issuer in { ca = local.issuers.ca.name } : issuer_id => issuer
    if can(var.helm_values[0].cert-manager.tlsCrt) && can(var.helm_values[0].cert-manager.tlsKey)
    }, {
    for issuer_id, issuer in local.issuers.letsencrypt : issuer_id => issuer.name
    if var.helm_values[0].cert-manager.clusterIssuers.letsencrypt.enabled
  })
}
