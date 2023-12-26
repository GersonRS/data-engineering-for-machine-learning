resource "kubernetes_namespace" "gitlab_namespace" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}
data "utils_deep_merge_yaml" "provider" {
  input = [for i in local.provider : yamlencode(i)]
}
data "utils_deep_merge_yaml" "rails" {
  input = [for i in local.rails : yamlencode(i)]
}
data "utils_deep_merge_yaml" "registry" {
  input = [for i in local.registry : yamlencode(i)]
}
resource "kubernetes_secret" "gitlab_provider" {
  metadata {
    name      = "gitlab-provider"
    namespace = var.namespace
  }

  data = {
    provider = data.utils_deep_merge_yaml.provider.output
  }

  depends_on = [kubernetes_namespace.gitlab_namespace]
}
resource "kubernetes_secret" "gitlab_rails_storage" {
  metadata {
    name      = "gitlab-rails-storage"
    namespace = var.namespace
  }

  data = {
    connection = data.utils_deep_merge_yaml.rails.output
  }

  depends_on = [kubernetes_namespace.gitlab_namespace]
}
resource "kubernetes_secret" "gitlab_registry_storage" {
  metadata {
    name      = "gitlab-registry-storage"
    namespace = var.namespace
  }

  data = {
    config = data.utils_deep_merge_yaml.registry.output
  }

  depends_on = [kubernetes_namespace.gitlab_namespace]
}

resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "argocd_project" "this" {
  count = var.argocd_project == null ? 1 : 0

  metadata {
    name      = var.destination_cluster != "in-cluster" ? "gitlab-${var.destination_cluster}" : "gitlab"
    namespace = var.argocd_namespace
    annotations = {
      "modern-devops-stack.io/argocd_namespace" = var.argocd_namespace
    }
  }

  spec {
    description  = "Gitlab application project for cluster ${var.destination_cluster}"
    source_repos = ["https://github.com/GersonRS/data-engineering-for-machine-learning.git"]

    destination {
      name      = var.destination_cluster
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

resource "argocd_application" "this" {
  metadata {
    name      = var.destination_cluster != "in-cluster" ? "gitlab-${var.destination_cluster}" : "gitlab"
    namespace = var.argocd_namespace
    labels = merge({
      "application" = "gitlab"
      "cluster"     = var.destination_cluster
    }, var.argocd_labels)
  }

  timeouts {
    create = "15m"
    delete = "15m"
  }

  wait = var.app_autosync == { "allow_empty" = tobool(null), "prune" = tobool(null), "self_heal" = tobool(null) } ? false : true

  spec {
    project = var.argocd_project == null ? argocd_project.this[0].metadata.0.name : var.argocd_project

    source {
      repo_url        = "https://github.com/GersonRS/data-engineering-for-machine-learning.git"
      path            = "charts/gitlab"
      target_revision = var.target_revision
      helm {
        values = data.utils_deep_merge_yaml.values.output
      }
    }

    destination {
      name      = var.destination_cluster
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
    kubernetes_namespace.gitlab_namespace,
    kubernetes_secret.gitlab_provider,
    kubernetes_secret.gitlab_rails_storage,
    kubernetes_secret.gitlab_registry_storage
  ]
}

resource "null_resource" "this" {
  depends_on = [
    resource.argocd_application.this,
  ]
}
