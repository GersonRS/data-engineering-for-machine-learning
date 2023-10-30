# Providers configuration

# These providers depend on the output of the respectives modules declared below.
# However, for clarity and ease of maintenance we grouped them all together in this section.

provider "kubernetes" {
  host                   = module.kind.parsed_kubeconfig.host
  client_certificate     = module.kind.parsed_kubeconfig.client_certificate
  client_key             = module.kind.parsed_kubeconfig.client_key
  cluster_ca_certificate = module.kind.parsed_kubeconfig.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = module.kind.parsed_kubeconfig.host
    client_certificate     = module.kind.parsed_kubeconfig.client_certificate
    client_key             = module.kind.parsed_kubeconfig.client_key
    cluster_ca_certificate = module.kind.parsed_kubeconfig.cluster_ca_certificate
  }
}

provider "argocd" {
  server_addr                 = "127.0.0.1:8080"
  auth_token                  = module.argocd_bootstrap.argocd_auth_token
  insecure                    = true
  plain_text                  = true
  port_forward                = true
  port_forward_with_namespace = module.argocd_bootstrap.argocd_namespace
  kubernetes {
    host                   = module.kind.parsed_kubeconfig.host
    client_certificate     = module.kind.parsed_kubeconfig.client_certificate
    client_key             = module.kind.parsed_kubeconfig.client_key
    cluster_ca_certificate = module.kind.parsed_kubeconfig.cluster_ca_certificate
  }
}

provider "keycloak" {
  client_id                = "admin-cli"
  username                 = module.keycloak.admin_credentials.username
  password                 = module.keycloak.admin_credentials.password
  url                      = "https://keycloak.apps.${local.cluster_name}.${local.base_domain}"
  tls_insecure_skip_verify = true
  initial_login            = false
}

# Module declarations and configuration

module "kind" {
  source = "./modules/kind"

  cluster_name       = local.cluster_name
  kubernetes_version = local.kubernetes_version
}

module "metallb" {
  source = "./modules/metallb"
  subnet = module.kind.kind_subnet
}

module "argocd_bootstrap" {
  source = "./modules/argocd"
}

module "traefik" {
  source       = "./modules/traefik"
  cluster_name = local.cluster_name
  # TODO fix: the base domain is defined later. Proposal: remove redirection from traefik module and add it in dependent modules.
  # For now random value is passed to base_domain. Redirections will not work before fix.
  base_domain            = "172-18-0-100.nip.io"
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  dependency_ids = {
    argocd = module.argocd_bootstrap.id
  }
}

module "cert-manager" {
  source                 = "./modules/cert-manager"
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  dependency_ids = {
    argocd = module.argocd_bootstrap.id
  }
}


module "postgresql" {
  source                 = "./modules/postgresql"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
  }
}

module "spark" {
  source           = "./modules/spark"
  cluster_name     = local.cluster_name
  base_domain      = local.base_domain
  cluster_issuer   = local.cluster_issuer
  argocd_namespace = module.argocd_bootstrap.argocd_namespace
  target_revision  = local.target_revision
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
  }
}

module "strimzi" {
  source           = "./modules/strimzi"
  cluster_name     = local.cluster_name
  base_domain      = local.base_domain
  cluster_issuer   = local.cluster_issuer
  argocd_namespace = module.argocd_bootstrap.argocd_namespace
  target_revision  = local.target_revision
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
  }
}
# module "cp-schema-registry" {
#   source           = "./modules/cp-schema-registry"
#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd_bootstrap.argocd_namespace
#   target_revision  = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#   }
# }

# module "mysql" {
#   source                 = "./modules/mysql"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd_bootstrap.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     oidc         = module.oidc.id
#   }
# }

module "keycloak" {
  source           = "./modules/keycloak"
  cluster_name     = local.cluster_name
  base_domain      = local.base_domain
  cluster_issuer   = local.cluster_issuer
  argocd_namespace = module.argocd_bootstrap.argocd_namespace
  target_revision  = local.target_revision
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
  }
}

module "oidc" {
  source         = "./modules/oidc"
  cluster_name   = local.cluster_name
  base_domain    = local.base_domain
  cluster_issuer = local.cluster_issuer
  dependency_ids = {
    keycloak = module.keycloak.id
    traefik  = module.traefik.id
    cert     = module.cert-manager.id
  }
}

module "minio" {
  source                 = "./modules/minio"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  oidc                   = module.oidc.oidc
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
    oidc         = module.oidc.id
  }
}

module "pinot" {
  source                 = "./modules/pinot"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision

  storage = {
    bucket_name       = "pinot"
    endpoint          = module.minio.cluster_dns
    access_key        = module.minio.minio_root_user_credentials.username
    secret_access_key = module.minio.minio_root_user_credentials.password
  }
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
    oidc         = module.oidc.id
    minio        = module.minio.id
  }
}

module "mlflow" {
  source                 = "./modules/mlflow"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  oidc                   = module.oidc.oidc
  storage = {
    bucket_name       = "mlflow"
    endpoint          = module.minio.cluster_dns
    access_key        = module.minio.minio_root_user_credentials.username
    secret_access_key = module.minio.minio_root_user_credentials.password
  }
  database = {
    user     = module.postgresql.credentials.user
    password = module.postgresql.credentials.password
    database = "mlflow"
    service  = module.postgresql.cluster_ip
  }
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
    oidc         = module.oidc.id
    minio        = module.minio.id
    postgresql   = module.postgresql.id
  }
}

# module "ray" {
#   source           = "./modules/ray"
#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd_bootstrap.argocd_namespace
#   target_revision        = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     minio        = module.minio.id
#     postgresql   = module.postgresql.id
#   }
# }

module "jupyterhub" {
  source                 = "./modules/jupyterhub"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  oidc                   = module.oidc.oidc
  storage = {
    bucket_name       = "jupyterhub"
    endpoint          = module.minio.cluster_dns
    access_key        = module.minio.minio_root_user_credentials.username
    secret_access_key = module.minio.minio_root_user_credentials.password
  }
  database = {
    user     = module.postgresql.credentials.user
    password = module.postgresql.credentials.password
    database = "jupyterhub"
    service  = module.postgresql.cluster_ip
  }
  mlflow = {
    cluster_ip = module.mlflow.cluster_ip
  }
  # ray = {
  #   endpoint = module.ray.endpoint
  # }
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
    oidc         = module.oidc.id
    minio        = module.minio.id
    postgresql   = module.postgresql.id
    mlflow       = module.mlflow.id
  }
}

module "airflow" {
  source                 = "./modules/airflow"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  oidc                   = module.oidc.oidc
  fernetKey              = local.airflow_fernetKey
  storage = {
    bucket_name       = "airflow"
    endpoint          = module.minio.cluster_ip
    access_key        = module.minio.minio_root_user_credentials.username
    secret_access_key = module.minio.minio_root_user_credentials.password
  }
  database = {
    user     = module.postgresql.credentials.user
    password = module.postgresql.credentials.password
    database = "airflow"
    service  = module.postgresql.cluster_ip
  }
  mlflow = {
    cluster_ip = module.mlflow.cluster_ip
  }
  # ray = {
  #   endpoint = module.ray.endpoint
  # }
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
    oidc         = module.oidc.id
    minio        = module.minio.id
  }
}
