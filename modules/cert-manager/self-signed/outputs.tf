output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = module.cert-manager.id
}

output "cluster_issuers" {
  description = "List of cluster issuers created by cert-manager."
  value       = module.cert-manager.cluster_issuers
}

output "ca_issuer_certificate" {
  description = "The CA certificate used by the `ca-issuer`. You can copy this value into a `*.pem` file and use it as a CA certificate in your browser to avoid having insecure warnings."
  value       = trimspace(resource.tls_self_signed_cert.root.cert_pem)
  sensitive   = true
}
