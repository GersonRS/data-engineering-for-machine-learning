output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "grafana_admin_password" {
  description = "The admin password for Grafana."
  value       = local.grafana.admin_password
  sensitive   = true
}
