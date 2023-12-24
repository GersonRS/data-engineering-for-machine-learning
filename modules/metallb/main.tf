# metallb_crds release is a hack to make sure CRDs are installed before CRs.
# Subchart is decompressed in this module on purpose
# TODO find a better way to manage this.
resource "helm_release" "metallb_crds" {
  name             = "metallb-crds"
  chart            = "${path.root}/charts/metallb/charts/metallb/charts/crds"
  namespace        = var.namespace
  create_namespace = true
  timeout          = 900
}

resource "helm_release" "metallb" {
  name              = "metallb"
  chart             = "${path.root}/charts/metallb/"
  namespace         = var.namespace
  dependency_update = true
  create_namespace  = true
  timeout           = 900
  values            = [data.utils_deep_merge_yaml.values.output]

  depends_on = [
    resource.helm_release.metallb_crds
  ]
}

data "utils_deep_merge_yaml" "values" {
  input = [for i in concat(local.helm_values, var.helm_values) : yamlencode(i)]
}
