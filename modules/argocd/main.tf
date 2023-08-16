# argocd secret key for token generation, it should be passed to next argocd generation
resource "random_password" "argocd_server_secretkey" {
  length  = 32
  special = false
}

# jwt token for `pipeline` account
resource "jwt_hashed_token" "argocd" {
  algorithm   = "HS256"
  secret      = random_password.argocd_server_secretkey.result
  claims_json = jsonencode(local.jwt_token_payload)
}

resource "time_static" "iat" {}

resource "random_uuid" "jti" {}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = local.argocd_chart.repository
  chart      = local.argocd_chart.chart
  version    = local.argocd_chart.version

  namespace         = var.namespace
  dependency_update = true
  create_namespace  = true
  timeout           = 10800
  values            = [data.utils_deep_merge_yaml.values.output]

  lifecycle {
    ignore_changes = all
  }
}

data "utils_deep_merge_yaml" "values" {
  input       = [for i in concat([local.helm_values.0.argo-cd], [var.helm_values.0.argo-cd]) : yamlencode(i)]
  append_list = true
}

resource "null_resource" "this" {
  depends_on = [
    resource.helm_release.argocd,
  ]
}
