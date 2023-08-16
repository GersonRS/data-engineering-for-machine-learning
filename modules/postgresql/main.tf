resource "random_password" "password_secret" {
  length  = 32
  special = false
}

resource "kubernetes_namespace" "postgresql_namespace" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "kubernetes_secret" "postgresql_secret" {
  metadata {
    name = "postgres-secrets"
    namespace = var.namespace
  }

  data = {
    password = "${resource.random_password.password_secret.result}"
    postgres-password = "${resource.random_password.password_secret.result}"
    replicationPasswordKey = "${resource.random_password.password_secret.result}"
  }

  depends_on = [ kubernetes_namespace.postgresql_namespace ]
}

resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "argocd_project" "this" {
  depends_on = [ kubernetes_secret.postgresql_secret ]
  metadata {
    name      = "postgresql"
    namespace = var.argocd_namespace
    annotations = {
      "modern-devops-stack.io/argocd_namespace" = var.argocd_namespace
    }
  }

  spec {
    description  = "postgresql application project"
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
  input = [for i in concat(local.helm_values, var.helm_values) : yamlencode(i)]
}

resource "argocd_application" "this" {
  metadata {
    name      = "postgresql"
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
      path            = "modules/postgresql/charts/postgresql"
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
    kubernetes_secret.postgresql_secret,
    argocd_project.this,
    resource.null_resource.dependencies,
  ]
}

resource "null_resource" "this" {
  depends_on = [
    resource.argocd_application.this,
  ]
}

data "kubernetes_service" "postgresql" {
  metadata {
    name      = "postgresql"
    namespace = var.namespace
  }

  depends_on = [
    null_resource.this
  ]
}
