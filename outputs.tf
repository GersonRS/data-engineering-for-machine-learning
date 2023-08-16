output "credentials" {
  description = "Map containing the credentials of each created user."
  value       = nonsensitive(module.oidc.devops_stack_users_passwords)
  sensitive   = true
}

output "jupyterhub_url" {
  value = module.jupyterhub.endpoint
  sensitive   = false
}
output "mlflow_url" {
  value = module.mlflow.endpoint
  sensitive   = false
}
output "minio_url" {
  value = module.minio.endpoint
  sensitive   = false
}
