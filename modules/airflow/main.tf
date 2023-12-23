
resource "null_resource" "dependencies" {
  triggers = var.dependency_ids
}

resource "random_password" "airflow_webserver_secret_key" {
  length  = 16
  special = false
  depends_on = [
    resource.null_resource.dependencies,
  ]
}
resource "kubernetes_namespace" "airflow_namespace" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
  depends_on = [
    resource.null_resource.dependencies,
  ]
}

resource "kubernetes_secret" "airflow_ssh_secret" {
  metadata {
    name      = "airflow-ssh-secret"
    namespace = var.namespace
  }

  data = {
    gitSshKey = file("${var.home_ssh}")
  }

  depends_on = [kubernetes_namespace.airflow_namespace]
}

resource "argocd_project" "this" {
  metadata {
    name      = "airflow"
    namespace = var.argocd_namespace
    annotations = {
      "modern-devops-stack.io/argocd_namespace" = var.argocd_namespace
    }
  }

  spec {
    description  = "airflow application project"
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
  depends_on = [
    resource.null_resource.dependencies,
  ]
}

data "utils_deep_merge_yaml" "values" {
  input = [for i in concat(local.helm_values, var.helm_values) : yamlencode(i)]
}

resource "argocd_application" "this" {

  metadata {
    name      = "airflow"
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
      path            = "helm-charts/airflow"
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
    kubernetes_secret.airflow_ssh_secret
  ]
}

resource "argocd_application" "access_control" {
  metadata {
    name      = "access-control"
    namespace = var.argocd_namespace
  }

  wait = var.app_autosync == { "allow_empty" = tobool(null), "prune" = tobool(null), "self_heal" = tobool(null) } ? false : true

  spec {
    project = argocd_project.this.metadata.0.name

    source {
      repo_url        = "https://github.com/GersonRS/data-engineering-for-machine-learning.git"
      path            = "yamls/access-control"
      target_revision = var.target_revision
      directory {
        recurse = true
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
    kubernetes_namespace.airflow_namespace
  ]
}

resource "null_resource" "this" {
  depends_on = [
    resource.argocd_application.this,
  ]
}
