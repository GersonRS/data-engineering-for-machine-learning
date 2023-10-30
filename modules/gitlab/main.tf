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
    name = "gitlab-provider"
    namespace = var.namespace
  }

  data = {
    provider = data.utils_deep_merge_yaml.provider.output
  }

  depends_on = [ kubernetes_namespace.gitlab_namespace ]
}
resource "kubernetes_secret" "gitlab_rails_storage" {
  metadata {
    name = "gitlab-rails-storage"
    namespace = var.namespace
  }

  data = {
    connection = data.utils_deep_merge_yaml.rails.output
  }

  depends_on = [ kubernetes_namespace.gitlab_namespace ]
}
resource "kubernetes_secret" "gitlab_registry_storage" {
  metadata {
    name = "gitlab-registry-storage"
    namespace = var.namespace
  }

  data = {
    config = data.utils_deep_merge_yaml.registry.output
  }

  depends_on = [ kubernetes_namespace.gitlab_namespace ]
}

resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "argocd_project" "this" {
  depends_on = [ kubernetes_namespace.gitlab_namespace ]
  metadata {
    name      = "gitlab"
    namespace = var.argocd_namespace
    annotations = {
      "modern-devops-stack.io/argocd_namespace" = var.argocd_namespace
    }
  }

  spec {
    description  = "gitlab application project"
    source_repos = ["https://github.com/GersonRS/modern-devops-stack.git"]

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

resource "argocd_application" "this" {
  metadata {
    name      = "gitlab"
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
      repo_url        = "https://github.com/GersonRS/modern-devops-stack.git"
      path            = "iac/modules/gitlab/charts/gitlab"
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
