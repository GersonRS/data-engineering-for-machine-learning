module "traefik" {
  source = "../"

  cluster_name     = var.cluster_name
  base_domain      = var.base_domain
  argocd_namespace = var.argocd_namespace

  target_revision        = var.target_revision
  namespace              = var.namespace
  enable_service_monitor = var.enable_service_monitor
  app_autosync           = var.app_autosync

  helm_values = concat(local.helm_values, var.helm_values)

  dependency_ids = var.dependency_ids
}

data "kubernetes_service" "traefik" {
  metadata {
    name      = replace(format("%s%s", local.helm_values.0.traefik.fullnameOverride, module.traefik.id), module.traefik.id ,"")
    namespace = var.namespace
  }
}
