output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "admin_credentials" {
  description = "Credentials for the administrator user of the master realm created on deployment."
  value       = data.kubernetes_secret.admin_credentials.data
  sensitive   = true
}
