module "loki-stack" {
  source = "../"

  argocd_namespace = var.argocd_namespace
  target_revision  = var.target_revision
  namespace        = var.namespace
  app_autosync     = var.app_autosync
  dependency_ids   = var.dependency_ids

  retention        = var.retention
  distributed_mode = var.distributed_mode
  ingress          = var.ingress
  enable_filebeat  = var.enable_filebeat

  helm_values = concat(local.helm_values, var.helm_values)
}
