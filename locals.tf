resource "random_password" "airflow_fernetKey" {
  length  = 32
  special = false
}
locals {
  app_autosync           = true ? { allow_empty = false, prune = true, self_heal = true } : {}
  kubernetes_version     = "v1.27.3"
  cluster_name           = "kind"
  base_domain            = format("%s.nip.io", replace(module.traefik.external_ip, ".", "-"))
  cluster_issuer         = "ca-issuer"
  enable_service_monitor = true
  target_revision        = "develop"
  airflow_fernetKey      = base64encode(resource.random_password.airflow_fernetKey.result)
}
