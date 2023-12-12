output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "admin_credentials" {
  description = "Credentials for the administrator user of the master realm created on deployment."
  value       = data.kubernetes_secret.admin_credentials.data
  sensitive   = true
}

output "cluster_dns" {
  description = "Keycloak cluster dns"
  value       = "keycloak.${var.namespace}.svc.cluster.local"
}
output "cluster_ip" {
  description = "Keycloak cluster ip internal"
  value       = data.kubernetes_service.keycloak.spec[0].cluster_ip
}

output "endpoint" {
  description = "Keycloak endpoint external"
  value       = "https://keycloak.apps.${var.cluster_name}.${var.base_domain}"
}
