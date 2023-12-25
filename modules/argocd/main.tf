resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "jwt_hashed_token" "tokens" {
  for_each = toset(var.extra_accounts)

  algorithm   = "HS256"
  secret      = var.server_secretkey
  claims_json = jsonencode(local.jwt_tokens[each.value])
}

resource "time_static" "iat" {
  for_each = toset(var.extra_accounts)
}

resource "random_uuid" "jti" {
  for_each = toset(var.extra_accounts)
}

resource "argocd_project" "this" {
  count = var.argocd_project == null ? 1 : 0

  metadata {
    name      = "argocd"
    namespace = var.argocd_namespace
    annotations = {
      "modern-devops-stack.io/argocd_namespace" = var.argocd_namespace
    }
  }

  spec {
    description  = "Argo CD application project"
    source_repos = ["https://github.com/GersonRS/data-engineering-for-machine-learning.git"]

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
  input       = [for i in concat(local.helm_values, var.helm_values) : yamlencode(i)]
  append_list = true
}

resource "argocd_application" "this" {
  metadata {
    name      = "argocd"
    namespace = var.argocd_namespace
    labels = merge({
      "application" = "argocd"
      "cluster"     = "in-cluster"
    }, var.argocd_labels)
  }

  wait    = var.app_autosync == { "allow_empty" = tobool(null), "prune" = tobool(null), "self_heal" = tobool(null) } ? false : true
  cascade = false

  spec {
    project = var.argocd_project == null ? argocd_project.this[0].metadata.0.name : var.argocd_project

    source {
      path            = "charts/argocd"
      repo_url        = "https://github.com/GersonRS/data-engineering-for-machine-learning.git"
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
      dynamic "automated" {
        for_each = toset(var.app_autosync == { "allow_empty" = tobool(null), "prune" = tobool(null), "self_heal" = tobool(null) } ? [] : [var.app_autosync])
        content {
          prune       = automated.value.prune
          self_heal   = automated.value.self_heal
          allow_empty = automated.value.allow_empty
        }
      }

      retry {
        backoff {
          duration     = "20s"
          max_duration = "2m"
          factor       = "2"
        }
        limit = "5"
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

resource "null_resource" "this" {
  depends_on = [
    resource.argocd_application.this,
  ]
}

