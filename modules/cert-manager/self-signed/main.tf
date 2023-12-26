resource "tls_private_key" "root" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "root" {
  private_key_pem = tls_private_key.root.private_key_pem

  subject {
    common_name  = "modern-devops-stack.gersonrs.com"
    organization = "GersonRS, SA"
  }

  validity_period_hours = 8760

  allowed_uses = [
    "cert_signing",
  ]

  is_ca_certificate = true
}

module "cert-manager" {
  source = "../"

  argocd_namespace       = var.argocd_namespace
  argocd_project         = var.argocd_project
  argocd_labels          = var.argocd_labels
  destination_cluster    = var.destination_cluster
  target_revision        = var.target_revision
  namespace              = var.namespace
  enable_service_monitor = var.enable_service_monitor
  deep_merge_append_list = var.deep_merge_append_list
  app_autosync           = var.app_autosync

  helm_values = concat(local.helm_values, var.helm_values)

  letsencrypt_issuer_email_main = "gersonrodriguessantos8@gmail.com"

  dependency_ids = var.dependency_ids
}
