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

resource "keycloak_saml_client" "gitlab" {
  realm_id                      = resource.keycloak_realm.modern_devops_stack.id
  name                          = "Gitlab"
  client_id                     = "gitlab"
  description                   = "Gitlab integration with keycloak"
  force_name_id_format          = true
  canonicalization_method       = "EXCLUSIVE"
  client_signature_required     = true
  enabled                       = true
  encrypt_assertions            = false
  force_post_binding            = true
  front_channel_logout          = true
  full_scope_allowed            = true
  include_authn_statement       = true
  name_id_format                = "persistent"
  sign_assertions               = true
  sign_documents                = true
  signature_key_name            = "KEY_ID"
  signature_algorithm           = "RSA_SHA256"
  root_url                      = "https://gitlab.apps.${var.cluster_name}.${var.base_domain}"
  master_saml_processing_url    = "https://gitlab.apps.${var.cluster_name}.${var.base_domain}/users/auth/saml/callback"
  login_theme                   = "keycloak"
  idp_initiated_sso_url_name    = "gitlab"
  idp_initiated_sso_relay_state = "gitlab.apps.${var.cluster_name}.${var.base_domain}"
  valid_redirect_uris = [
    "https://gitlab.apps.${var.cluster_name}.${var.base_domain}/*",
    "https://gitlab.apps.${var.cluster_name}.${var.base_domain}/users/auth/saml/callback",
  ]
  depends_on = [keycloak_realm.modern_devops_stack]
}

resource "keycloak_role" "gitlab_role_external" {
  client_id   = resource.keycloak_saml_client.gitlab.id
  realm_id    = resource.keycloak_realm.modern_devops_stack.id
  name        = "gitlab:external"
  description = "gitlab:external"
  depends_on  = [keycloak_saml_client.gitlab]
}
resource "keycloak_role" "gitlab_role_access" {
  client_id   = resource.keycloak_saml_client.gitlab.id
  realm_id    = resource.keycloak_realm.modern_devops_stack.id
  name        = "gitlab:access"
  description = "gitlab:access"
  depends_on  = [keycloak_saml_client.gitlab]
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
  description            = "OpenID Connect scope to map MinIO access policy to a claim"
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

resource "keycloak_saml_client_scope" "modern_devops_stack_name" {
  realm_id    = resource.keycloak_realm.modern_devops_stack.id
  name        = "gitlab_name"
  description = "SAML name"
  depends_on  = [keycloak_saml_client.gitlab, keycloak_realm.modern_devops_stack]
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_name_property" {
  realm_id                   = resource.keycloak_realm.modern_devops_stack.id
  client_scope_id            = resource.keycloak_saml_client_scope.modern_devops_stack_name.id
  name                       = "name"
  user_property              = "Username"
  friendly_name              = "Username"
  saml_attribute_name        = "name"
  saml_attribute_name_format = "Basic"
  depends_on                 = [keycloak_saml_client_scope.modern_devops_stack_name, keycloak_saml_client.gitlab, keycloak_realm.modern_devops_stack]
}
resource "keycloak_saml_client_scope" "modern_devops_stack_first_name" {
  realm_id    = resource.keycloak_realm.modern_devops_stack.id
  name        = "gitlab_first_name"
  description = "SAML first_name"
  depends_on  = [keycloak_saml_client.gitlab, keycloak_realm.modern_devops_stack]
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_first_name_property" {
  realm_id                   = resource.keycloak_realm.modern_devops_stack.id
  client_scope_id            = resource.keycloak_saml_client_scope.modern_devops_stack_first_name.id
  name                       = "first_name"
  user_property              = "FirstName"
  friendly_name              = "First Name"
  saml_attribute_name        = "first_name"
  saml_attribute_name_format = "Basic"
  depends_on                 = [keycloak_saml_client_scope.modern_devops_stack_first_name, keycloak_saml_client.gitlab, keycloak_realm.modern_devops_stack]
}
resource "keycloak_saml_client_scope" "modern_devops_stack_last_name" {
  realm_id    = resource.keycloak_realm.modern_devops_stack.id
  name        = "gitlab_last_name"
  description = "SAML last_name"
  depends_on  = [keycloak_saml_client.gitlab, keycloak_realm.modern_devops_stack]
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_last_name_property" {
  realm_id                   = resource.keycloak_realm.modern_devops_stack.id
  client_scope_id            = resource.keycloak_saml_client_scope.modern_devops_stack_last_name.id
  name                       = "last_name"
  user_property              = "LastName"
  friendly_name              = "Last Name"
  saml_attribute_name        = "last_name"
  saml_attribute_name_format = "Basic"
  depends_on                 = [keycloak_saml_client_scope.modern_devops_stack_last_name, keycloak_saml_client.gitlab, keycloak_realm.modern_devops_stack]
}
resource "keycloak_saml_client_scope" "modern_devops_stack_email" {
  realm_id    = resource.keycloak_realm.modern_devops_stack.id
  name        = "gitlab_email"
  description = "SAML email"
  depends_on  = [keycloak_saml_client.gitlab, keycloak_realm.modern_devops_stack]
}

resource "keycloak_saml_user_property_protocol_mapper" "gitlab_email_property" {
  realm_id                   = resource.keycloak_realm.modern_devops_stack.id
  client_scope_id            = resource.keycloak_saml_client_scope.modern_devops_stack_email.id
  name                       = "email"
  user_property              = "Email"
  friendly_name              = "Email"
  saml_attribute_name        = "email"
  saml_attribute_name_format = "Basic"
  depends_on                 = [keycloak_saml_client_scope.modern_devops_stack_email, keycloak_saml_client.gitlab, keycloak_realm.modern_devops_stack]
}
resource "keycloak_saml_client_scope" "modern_devops_stack_roles" {
  realm_id    = resource.keycloak_realm.modern_devops_stack.id
  name        = "gitlab_roles"
  description = "SAML roles"
  depends_on  = [keycloak_saml_client.gitlab, keycloak_realm.modern_devops_stack]
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
  depends_on = [
    keycloak_realm.modern_devops_stack,
    keycloak_openid_client.modern_devops_stack,
    keycloak_openid_user_attribute_protocol_mapper.modern_devops_stack_minio_policy,
    keycloak_openid_user_attribute_protocol_mapper.modern_devops_stack_username,
    keycloak_openid_group_membership_protocol_mapper.modern_devops_stack_groups,
    keycloak_openid_client_scope.modern_devops_stack_groups,
    keycloak_openid_client_scope.modern_devops_stack_minio_policy,
    keycloak_openid_client_scope.modern_devops_stack_username
  ]
}

resource "keycloak_saml_client_default_scopes" "client_default_scopes" {
  realm_id  = resource.keycloak_realm.modern_devops_stack.id
  client_id = resource.keycloak_saml_client.gitlab.id
  default_scopes = [
    "role_list",
    "gitlab_first_name",
    "gitlab_last_name",
    "gitlab_email",
    "gitlab_name",
    "gitlab_roles"
  ]
  depends_on = [
    keycloak_saml_client.gitlab,
    keycloak_realm.modern_devops_stack,
    keycloak_saml_client_scope.modern_devops_stack_roles,
    keycloak_saml_user_property_protocol_mapper.gitlab_email_property,
    keycloak_saml_user_property_protocol_mapper.gitlab_first_name_property,
    keycloak_saml_user_property_protocol_mapper.gitlab_last_name_property,
    keycloak_saml_user_property_protocol_mapper.gitlab_name_property
  ]
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
  depends_on = [
    keycloak_realm.modern_devops_stack,
    keycloak_openid_client.modern_devops_stack,
    keycloak_openid_user_attribute_protocol_mapper.modern_devops_stack_minio_policy,
    keycloak_openid_user_attribute_protocol_mapper.modern_devops_stack_username,
    keycloak_openid_group_membership_protocol_mapper.modern_devops_stack_groups,
    keycloak_openid_client_scope.modern_devops_stack_groups,
    keycloak_openid_client_scope.modern_devops_stack_minio_policy,
    keycloak_openid_client_scope.modern_devops_stack_username
  ]
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
  depends_on = [keycloak_realm.modern_devops_stack, random_password.modern_devops_stack_users]
}

resource "keycloak_user_groups" "modern_devops_stack_admins" {
  for_each = var.user_map

  user_id  = resource.keycloak_user.modern_devops_stack_users[each.key].id
  realm_id = resource.keycloak_realm.modern_devops_stack.id
  group_ids = [
    resource.keycloak_group.modern_devops_stack_admins.id
  ]
  depends_on = [keycloak_realm.modern_devops_stack,
    keycloak_user.modern_devops_stack_users,
  keycloak_group.modern_devops_stack_admins]
}

resource "null_resource" "this" {
  depends_on = [
    keycloak_realm.modern_devops_stack,
    keycloak_group.modern_devops_stack_admins,
    keycloak_user.modern_devops_stack_users,
    keycloak_user_groups.modern_devops_stack_admins,
    keycloak_saml_client_default_scopes.client_default_scopes,
    keycloak_openid_client_default_scopes.client_default_scopes
  ]
}


data "keycloak_realm_keys" "realm_keys" {
  realm_id   = resource.keycloak_realm.modern_devops_stack.id
  algorithms = ["RS256"]
}

# resource "ah_ssh_key" "realm_keys_fingerprint" {
#   name = "idp_cert_fingerprint"
#   public_key = data.keycloak_realm_keys.realm_keys.keys[0].certificate
# }

data "external" "fingerprint_generator" {
  program = ["bash", "${path.module}/t.sh"]

  query = {
    cert = "-----BEGIN CERTIFICATE-----\n${data.keycloak_realm_keys.realm_keys.keys[0].certificate}\n-----END CERTIFICATE-----"
  }
}
