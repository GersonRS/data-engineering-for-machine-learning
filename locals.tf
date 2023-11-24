resource "random_password" "airflow_fernetKey" {
  length  = 32
  special = false
}
locals {
  kubernetes_version     = "v1.27.1"
  cluster_name           = "kind"
  base_domain            = format("%s.nip.io", replace(module.traefik.external_ip, ".", "-"))
  cluster_issuer         = "ca-issuer"
  enable_service_monitor = false

  target_revision = "develop"
  airflow_fernetKey = base64encode(resource.random_password.airflow_fernetKey.result)
}
