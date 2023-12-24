output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = module.loki-stack.id
}

output "loki_credentials" {
  description = "Credentials to access the Loki ingress, if activated."
  value       = module.loki-stack.loki_credentials
  sensitive   = true
}
