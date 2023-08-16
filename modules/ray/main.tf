resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "random_password" "db_password" {
  count   = var.database == null ? 1 : 0
  length  = 32
  special = false
}

resource "argocd_project" "this" {
  metadata {
    name      = "ray"
    namespace = var.argocd_namespace
  }

  spec {
    description = "ray application project"
    source_repos = [
      "https://github.com/GersonRS/data-engineering-for-machine-learning.git",
    ]

    destination {
      name      = "in-cluster"
      namespace = var.namespace
    }

    orphaned_resources {
      warn = true
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }
  }
}

data "utils_deep_merge_yaml" "values" {
  input = [for i in concat(local.helm_values, var.helm_values) : yamlencode(i)]
}

resource "argocd_application" "operator" {
  metadata {
    name      = "ray-operator"
    namespace = var.argocd_namespace
  }

  wait = var.app_autosync == { "allow_empty" = tobool(null), "prune" = tobool(null), "self_heal" = tobool(null) } ? false : true

  spec {
    project = argocd_project.this.metadata.0.name

    source {
      repo_url        = "https://github.com/GersonRS/data-engineering-for-machine-learning.git"
      path            = "modules/ray/charts/kuberay-operator"
      target_revision = var.target_revision
    }

    destination {
      name      = "in-cluster"
      namespace = var.namespace
    }

    sync_policy {
      automated {
        allow_empty = var.app_autosync.allow_empty
        prune       = var.app_autosync.prune
        self_heal   = var.app_autosync.self_heal
      }

      retry {
        backoff {
          duration     = ""
          max_duration = ""
          factor       = "2"
        }
        limit = "0"
      }

      sync_options = [
        "CreateNamespace=true"
      ]
    }
  }

  depends_on = [
    resource.null_resource.dependencies,
  ]
}

resource "argocd_application" "this" {
  metadata {
    name      = "ray"
    namespace = var.argocd_namespace
  }

  timeouts {
    create = "15m"
    delete = "15m"
  }

  wait = var.app_autosync == { "allow_empty" = tobool(null), "prune" = tobool(null), "self_heal" = tobool(null) } ? false : true

  spec {
    project = argocd_project.this.metadata.0.name

    source {
      repo_url        = "https://github.com/GersonRS/data-engineering-for-machine-learning.git"
      path            = "modules/ray/charts/ray-cluster"
      target_revision = var.target_revision
      helm {
        values = data.utils_deep_merge_yaml.values.output
      }
    }

    destination {
      name      = "in-cluster"
      namespace = var.namespace
    }

    sync_policy {
      automated {
        allow_empty = var.app_autosync.allow_empty
        prune       = var.app_autosync.prune
        self_heal   = var.app_autosync.self_heal
      }

      retry {
        backoff {
          duration     = ""
          max_duration = ""
          factor       = "2"
        }
        limit = "0"
      }

      sync_options = [
        "CreateNamespace=true"
      ]
    }
  }

  depends_on = [
    resource.argocd_application.operator,
  ]
}


# resource "null_resource" "wait_for_ray" {
#   provisioner "local-exec" {
#     command = <<EOT
#     while [ $(curl -k https://ray.apps.${var.cluster_name}.${var.base_domain} -I -s | head -n 1 | cut -d' ' -f2) != '200' ]; do
#       sleep 5
#     done
#     EOT
#   }

#   depends_on = [
#     resource.argocd_application.this,
#   ]
# }

# data "kubernetes_secret" "admin_credentials" {
#   metadata {
#     name      = "ray-initial-admin"
#     namespace = var.namespace
#   }
#   depends_on = [
#     resource.null_resource.wait_for_ray,
#   ]
# }

resource "null_resource" "this" {
  depends_on = [
    resource.argocd_application.this,
  ]
}
