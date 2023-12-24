resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "keycloak_realm" "devops_stack" {
  realm                    = "devops-stack"
  display_name             = "DevOps Stack"
  display_name_html        = "<img width='200px' src='https://raw.githubusercontent.com/camptocamp/devops-stack/gh-pages/images/devops-stack-logo_light_by_c2c_black.png' alt='DevOps Stack Logo'/>"
  login_with_email_allowed = true
  access_code_lifespan     = "1h"
  ssl_required             = "external"
  password_policy          = "upperCase(1) and length(8) and forceExpiredPasswordChange(365) and notUsername"
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

resource "keycloak_openid_client" "devops_stack" {
  realm_id                     = resource.keycloak_realm.devops_stack.id
  name                         = "DevOps Stack Applications"
  client_id                    = local.oidc.client_id
  client_secret                = resource.random_password.client_secret.result
  access_type                  = "CONFIDENTIAL"
  standard_flow_enabled        = true
  direct_access_grants_enabled = true
  valid_redirect_uris          = var.oidc_redirect_uris
}

resource "keycloak_openid_client_scope" "devops_stack_groups" {
  realm_id               = resource.keycloak_realm.devops_stack.id
  name                   = "groups"
  description            = "OpenID Connect scope to map a user's group memberships to a claim"
  include_in_token_scope = true
}

resource "keycloak_openid_client_scope" "devops_stack_minio_policy" {
  realm_id               = resource.keycloak_realm.devops_stack.id
  name                   = "minio-policy"
  description            = "OpenID Connect scope to map MinIO access policy to a claim"
  include_in_token_scope = true
}

resource "keycloak_openid_group_membership_protocol_mapper" "devops_stack_groups" {
  realm_id        = resource.keycloak_realm.devops_stack.id
  client_scope_id = resource.keycloak_openid_client_scope.devops_stack_groups.id
  name            = "groups"
  claim_name      = "groups"
  full_path       = false
}

resource "keycloak_openid_user_attribute_protocol_mapper" "devops_stack_minio_policy" {
  realm_id             = resource.keycloak_realm.devops_stack.id
  client_scope_id      = resource.keycloak_openid_client_scope.devops_stack_minio_policy.id
  name                 = "minio-policy"
  user_attribute       = "policy"
  claim_name           = "policy"
  multivalued          = true
  aggregate_attributes = true
  add_to_id_token      = true
  claim_value_type     = "String"
}

resource "keycloak_openid_client_default_scopes" "client_default_scopes" {
  realm_id  = resource.keycloak_realm.devops_stack.id
  client_id = resource.keycloak_openid_client.devops_stack.id
  default_scopes = [
    "profile",
    "email",
    "roles",
    resource.keycloak_openid_client_scope.devops_stack_groups.name,
    resource.keycloak_openid_client_scope.devops_stack_minio_policy.name,
  ]
}

resource "keycloak_group" "devops_stack_admins" {
  realm_id = resource.keycloak_realm.devops_stack.id
  name     = "devops-stack-admins"
  attributes = {
    "terraform" = "true"
    "policy"    = "consoleAdmin##readwrite##diagnostics"
  }
}

resource "random_password" "devops_stack_users" {
  for_each = var.user_map

  length  = 32
  special = false
}

resource "keycloak_user" "devops_stack_users" {
  for_each = var.user_map

  realm_id = resource.keycloak_realm.devops_stack.id
  username = each.value.username
  initial_password {
    value = resource.random_password.devops_stack_users[each.key].result
  }
  first_name     = each.value.first_name
  last_name      = each.value.last_name
  email          = each.value.email
  email_verified = true
  attributes = {
    "terraform" = "true"
  }
}

resource "keycloak_user_groups" "devops_stack_admins" {
  for_each = var.user_map

  user_id  = resource.keycloak_user.devops_stack_users[each.key].id
  realm_id = resource.keycloak_realm.devops_stack.id
  group_ids = [
    resource.keycloak_group.devops_stack_admins.id
  ]
}

resource "null_resource" "this" {
  depends_on = [
    resource.keycloak_realm.devops_stack,
    resource.keycloak_group.devops_stack_admins,
    resource.keycloak_user_groups.devops_stack_admins,
  ]
}
