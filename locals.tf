locals {
  kubernetes_version     = "v1.27.1"
  cluster_name           = "kind"
  base_domain            = format("%s.nip.io", replace(module.traefik.external_ip, ".", "-"))
  cluster_issuer         = "ca-issuer"
  enable_service_monitor = false

  username = nonsensitive(keys(module.oidc.devops_stack_users_passwords)[0])
  password = nonsensitive(values(module.oidc.devops_stack_users_passwords)[0])
}
