output "ingress_domain" {
  description = "The domain to use for accessing the applications."
  value       = "${local.cluster_name}.${local.base_domain}"
}

output "keycloak_admin_credentials" {
  description = "Credentials for the administrator user of the Keycloak server."
  value       = module.keycloak.admin_credentials
  sensitive   = true
}

output "keycloak_users" {
  description = "Map containing the credentials of each created user."
  value       = module.oidc.modern_devops_stack_users_passwords
  sensitive   = true
}
