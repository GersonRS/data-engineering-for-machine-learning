output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = module.kube-prometheus-stack.id
}

output "grafana_admin_password" {
  description = "The admin password for Grafana."
  value       = module.kube-prometheus-stack.grafana_admin_password
  sensitive   = true
}
