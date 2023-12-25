output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "oidc" {
  description = "Object containing multiple OIDC configuration values."
  value       = local.oidc
  sensitive   = true
}

output "modern_devops_stack_users_passwords" {
  description = "Map containing the credentials of each created user."
  value = {
    for key, value in var.user_map : value.username => resource.random_password.modern_devops_stack_users[key].result
  }
  sensitive = true
}

# show certificate of first key:
output "certificate" {
  value = data.keycloak_realm_keys.realm_keys.keys[0].certificate
}
output "fingerprint" {
  value = local.oidc.fingerprint
}
