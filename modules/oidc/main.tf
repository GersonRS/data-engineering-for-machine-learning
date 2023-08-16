resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "keycloak_realm" "modern_devops_stack" {
  realm                       = "modern-devops-stack"
  display_name                = "Modern DevOps Stack"
  display_name_html           = "<img width='200px' src='https://raw.githubusercontent.com/GersonRS/modern-devops-stack/main/.github/assets/images/logo.png' alt='Modern DevOps Stack Logo'/>"
  login_with_email_allowed    = true
  default_signature_algorithm = "RS256"
  access_code_lifespan        = "1h"
  ssl_required                = "external"
  password_policy             = "upperCase(1) and length(8) and forceExpiredPasswordChange(365) and notUsername"
  attributes = {
    terraform = "true"
  }

  depends_on = [
    resource.null_resource.dependencies
  ]
}

resource "random_password" "client_secret" {
  length  = 32
  special = false
}

resource "keycloak_openid_client" "modern_devops_stack" {
  realm_id                     = resource.keycloak_realm.modern_devops_stack.id
  name                         = "Modern DevOps Stack Applications"
  client_id                    = local.oidc.client_id
  client_secret                = resource.random_password.client_secret.result
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  valid_redirect_uris          = var.oidc_redirect_uris
  depends_on                   = [keycloak_realm.modern_devops_stack]
}

resource "keycloak_openid_client_scope" "modern_devops_stack_groups" {
  realm_id               = resource.keycloak_realm.modern_devops_stack.id
  name                   = "groups"
  description            = "OpenID Connect scope to map a user's group memberships to a claim"
  include_in_token_scope = true
  depends_on             = [keycloak_openid_client.modern_devops_stack, keycloak_realm.modern_devops_stack]
}

resource "keycloak_openid_client_scope" "modern_devops_stack_minio_policy" {
  realm_id               = resource.keycloak_realm.modern_devops_stack.id
  name                   = "minio-policy"
  description            = "OpenID Connect scope to map minio access policy to a claim"
  include_in_token_scope = true
  depends_on             = [keycloak_openid_client.modern_devops_stack, keycloak_realm.modern_devops_stack]
}

resource "keycloak_openid_client_scope" "modern_devops_stack_username" {
  realm_id               = resource.keycloak_realm.modern_devops_stack.id
  name                   = "username"
  description            = "OpenID Connect built-in scope: username"
  include_in_token_scope = true
  depends_on             = [keycloak_openid_client.modern_devops_stack, keycloak_realm.modern_devops_stack]
}

resource "keycloak_openid_group_membership_protocol_mapper" "modern_devops_stack_groups" {
  realm_id        = resource.keycloak_realm.modern_devops_stack.id
  client_scope_id = resource.keycloak_openid_client_scope.modern_devops_stack_groups.id
  name            = "groups"
  claim_name      = "groups"
  full_path       = false
  depends_on      = [keycloak_openid_client_scope.modern_devops_stack_groups]
}

resource "keycloak_openid_user_attribute_protocol_mapper" "modern_devops_stack_minio_policy" {
  realm_id             = resource.keycloak_realm.modern_devops_stack.id
  client_scope_id      = resource.keycloak_openid_client_scope.modern_devops_stack_minio_policy.id
  name                 = "minio-policy"
  user_attribute       = "policy"
  claim_name           = "policy"
  multivalued          = true
  aggregate_attributes = true
  add_to_id_token      = true
  claim_value_type     = "String"
  depends_on           = [keycloak_openid_client_scope.modern_devops_stack_minio_policy]
}
resource "keycloak_openid_user_attribute_protocol_mapper" "modern_devops_stack_username" {
  realm_id             = resource.keycloak_realm.modern_devops_stack.id
  client_scope_id      = resource.keycloak_openid_client_scope.modern_devops_stack_username.id
  name                 = "username"
  user_attribute       = "username"
  claim_name           = "username"
  multivalued          = false
  aggregate_attributes = false
  add_to_id_token      = true
  claim_value_type     = "String"
  depends_on           = [keycloak_openid_client_scope.modern_devops_stack_username]
}

resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
  realm_id  = resource.keycloak_realm.modern_devops_stack.id
  client_id = resource.keycloak_openid_client.modern_devops_stack.id
  default_scopes = [
    "profile",
    "email",
    "roles",
    "username",
    resource.keycloak_openid_client_scope.modern_devops_stack_groups.name,
    resource.keycloak_openid_client_scope.modern_devops_stack_minio_policy.name,
  ]
  depends_on = [keycloak_openid_client.modern_devops_stack]
}

resource "keycloak_group" "modern_devops_stack_admins" {
  realm_id = resource.keycloak_realm.modern_devops_stack.id
  name     = "modern-devops-stack-admins"
  attributes = {
    "terraform" = "true"
    "policy"    = "consoleAdmin##readwrite##diagnostics"
  }
  depends_on = [keycloak_realm.modern_devops_stack]
}

resource "random_password" "modern_devops_stack_users" {
  for_each = var.user_map

  length  = 32
  special = false
}

resource "keycloak_user" "modern_devops_stack_users" {
  for_each = var.user_map

  realm_id = resource.keycloak_realm.modern_devops_stack.id
  username = each.value.username
  initial_password {
    value = resource.random_password.modern_devops_stack_users[each.key].result
  }
  first_name     = each.value.first_name
  last_name      = each.value.last_name
  email          = each.value.email
  email_verified = true
  attributes = {
    "terraform" = "true"
  }
  depends_on = [keycloak_realm.modern_devops_stack]
}

resource "keycloak_user_groups" "modern_devops_stack_admins" {
  for_each = var.user_map

  user_id  = resource.keycloak_user.modern_devops_stack_users[each.key].id
  realm_id = resource.keycloak_realm.modern_devops_stack.id
  group_ids = [
    resource.keycloak_group.modern_devops_stack_admins.id
  ]
  depends_on = [keycloak_realm.modern_devops_stack, keycloak_user.modern_devops_stack_users, keycloak_group.modern_devops_stack_admins]
}

resource "null_resource" "this" {
  depends_on = [
    resource.keycloak_realm.modern_devops_stack,
    resource.keycloak_group.modern_devops_stack_admins,
    resource.keycloak_user.modern_devops_stack_users,
    resource.keycloak_user_groups.modern_devops_stack_admins,
  ]
}
