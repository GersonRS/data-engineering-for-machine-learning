output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "loki_credentials" {
  description = "Credentials to access the Loki ingress, if activated."
  value = var.ingress != null ? {
    username = "loki"
    password = random_password.loki_password.0.result
  } : null
  sensitive = true
}
