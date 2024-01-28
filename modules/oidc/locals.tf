locals {
  oidc = {
    issuer_url    = format("https://keycloak.apps.%s.%s/realms/modern-gitops-stack", var.cluster_name, var.base_domain)
    oauth_url     = format("https://keycloak.apps.%s.%s/realms/modern-gitops-stack/protocol/openid-connect/auth", var.cluster_name, var.base_domain)
    token_url     = format("https://keycloak.apps.%s.%s/realms/modern-gitops-stack/protocol/openid-connect/token", var.cluster_name, var.base_domain)
    api_url       = format("https://keycloak.apps.%s.%s/realms/modern-gitops-stack/protocol/openid-connect/userinfo", var.cluster_name, var.base_domain)
    client_id     = "modern-gitops-stack-applications"
    client_secret = resource.random_password.client_secret.result
    oauth2_proxy_extra_args = var.cluster_issuer == "ca-issuer" || var.cluster_issuer == "letsencrypt-staging" ? [
      "--insecure-oidc-skip-issuer-verification=true",
      "--ssl-insecure-skip-verify=true",
    ] : []
    fingerprint = split("=", data.external.fingerprint_generator.result.fingerprint)[1]
  }
}
