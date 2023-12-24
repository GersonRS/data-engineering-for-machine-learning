module "loki-stack" {
  source = "../"

  argocd_namespace    = var.argocd_namespace
  argocd_project      = var.argocd_project
  argocd_labels       = var.argocd_labels
  destination_cluster = var.destination_cluster
  target_revision     = var.target_revision
  namespace           = var.namespace
  app_autosync        = var.app_autosync
  dependency_ids      = var.dependency_ids

  retention = var.retention
  ingress   = var.ingress

  helm_values = concat(local.helm_values, var.helm_values)
}
