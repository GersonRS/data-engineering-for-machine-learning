output "keycloak_users_credentials" {
  value = [
    for key, value in nonsensitive(module.oidc.devops_stack_users_passwords) : { "user" = key, "password" = nonsensitive(value) }
  ]
  sensitive = false
}
# output "jupyterhub_url" {
#   value = module.jupyterhub.endpoint
#   sensitive   = false
# }
# output "mlflow_url" {
#   value = module.mlflow.endpoint
#   sensitive   = false
# }
# output "minio_url" {
#   value     = module.minio.endpoint
#   sensitive = false
# }
output "keycloak_url" {
  value = module.keycloak.endpoint
}
output "keycloak_admin_credentials" {
  value     = nonsensitive(module.keycloak.admin_credentials)
  sensitive = false
}
output "postgresql_external_ip" {
  value = module.postgresql.external_ip
}
output "postgresql_user" {
  value     = module.postgresql.credentials.user
  sensitive = false
}
output "postgresql_password" {
  value     = nonsensitive(module.postgresql.credentials.password)
  sensitive = false
}
