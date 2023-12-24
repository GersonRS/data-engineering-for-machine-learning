# output "keycloak_users_credentials" {
#   value = [
#     for key, value in nonsensitive(module.oidc.devops_stack_users_passwords) : { "user" = key, "password" = nonsensitive(value) }
#   ]
#   sensitive = false
# }
# # output "jupyterhub_url" {
# #   value = module.jupyterhub.endpoint
# #   sensitive   = false
# # }
# output "mlflow_url" {
#   value = module.mlflow.endpoint
#   sensitive   = false
# }
# output "minio_url" {
#   value     = module.minio.endpoint
#   sensitive = false
# }
# output "keycloak_url" {
#   value = module.keycloak.endpoint
# }
# output "keycloak_admin_credentials" {
#   value     = nonsensitive(module.keycloak.admin_credentials)
#   sensitive = false
# }
# output "postgresql_external_ip" {
#   value = module.postgresql.external_ip
# }
# output "postgresql_user" {
#   value     = module.postgresql.credentials.user
#   sensitive = false
# }
# output "postgresql_password" {
#   value     = nonsensitive(module.postgresql.credentials.password)
#   sensitive = false
# }
output "ingress_domain" {
  description = "The domain to use for accessing the applications."
  value       = "${local.cluster_name}.${local.base_domain}"
}

output "kubernetes_kubeconfig" {
  description = "Configuration that can be copied into `.kube/config in order to access the cluster with `kubectl`."
  value       = module.kind.raw_kubeconfig
  sensitive   = true
}

# output "keycloak_admin_credentials" {
#   description = "Credentials for the administrator user of the Keycloak server."
#   value       = module.keycloak.admin_credentials
#   sensitive   = true
# }

# output "keycloak_users" {
#   description = "Map containing the credentials of each created user."
#   value       = module.oidc.devops_stack_users_passwords
#   sensitive   = true
# }
