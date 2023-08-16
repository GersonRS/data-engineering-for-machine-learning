resource "tls_private_key" "root" {
  algorithm = "ECDSA"
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


module "self-signed" {
  source = "./self-signed"

  argocd_namespace = var.argocd_namespace

  target_revision        = var.target_revision
  namespace              = var.namespace
  enable_service_monitor = var.enable_service_monitor
  deep_merge_append_list = var.deep_merge_append_list
  app_autosync           = var.app_autosync

  helm_values = concat([{
    cert-manager = {
      tlsCrt = base64encode(tls_self_signed_cert.root.cert_pem)
      tlsKey = base64encode(tls_private_key.root.private_key_pem)
    }
  }], var.helm_values)

  dependency_ids = var.dependency_ids
}
