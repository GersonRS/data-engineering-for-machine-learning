module "kind" {
  source             = "./modules/kind"
  cluster_name       = local.cluster_name
  kubernetes_version = local.kubernetes_version
}

module "metallb" {
  source = "./modules/metallb"
  subnet = module.kind.kind_subnet
}

module "argocd" {
  source     = "./modules/argocd"
  depends_on = [module.kind]
}

module "traefik" {
  source                 = "./modules/traefik"
  cluster_name           = local.cluster_name
  base_domain            = "172-18-0-100.nip.io"
  argocd_namespace       = module.argocd.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  app_autosync           = local.app_autosync
  target_revision        = local.target_revision
  dependency_ids = {
    argocd = module.argocd.id
  }
}

module "cert-manager" {
  source                 = "./modules/cert-manager"
  argocd_namespace       = module.argocd.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  app_autosync           = local.app_autosync
  target_revision        = local.target_revision
  dependency_ids = {
    argocd = module.argocd.id
  }
}


# module "keycloak" {
#   source           = "./modules/keycloak"
#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd.argocd_namespace
#   app_autosync     = local.app_autosync
#   target_revision  = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#   }
# }

# module "oidc" {
#   source         = "./modules/oidc"
#   cluster_name   = local.cluster_name
#   base_domain    = local.base_domain
#   cluster_issuer = local.cluster_issuer
#   dependency_ids = {
#     keycloak = module.keycloak.id
#   }
# }

# module "minio" {
#   source                 = "./modules/minio"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   app_autosync           = local.app_autosync
#   target_revision        = local.target_revision
#   oidc                   = module.oidc.oidc
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     oidc         = module.oidc.id
#   }
# }

# module "loki-stack" {
#   source           = "./modules/loki-stack"
#   argocd_namespace = module.argocd.argocd_namespace
#   app_autosync     = local.app_autosync
#   target_revision  = local.target_revision
#   logs_storage = {
#     bucket_name = "loki-bucket"
#     endpoint    = module.minio.cluster_dns
#     access_key  = module.minio.minio_root_user_credentials.username
#     secret_key  = module.minio.minio_root_user_credentials.password
#   }
#   dependency_ids = {
#     minio = module.minio.id
#   }
# }

# module "reflector" {
#   source           = "./modules/reflector"
#   argocd_namespace = module.argocd.argocd_namespace
#   target_revision  = local.target_revision
#   dependency_ids = {
#     argocd = module.argocd.id
#   }
# }

# module "postgresql" {
#   source                 = "./modules/postgresql"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#   }
#   depends_on = [module.argocd, module.metallb, module.traefik, module.cert-manager]
# }

# module "spark" {
#   source           = "./modules/spark"
#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd.argocd_namespace
#   target_revision  = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#   }
# }

# module "strimzi" {
#   source           = "./modules/strimzi"
#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd.argocd_namespace
#   target_revision  = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#   }
# }
# module "kafka-broker" {
#   source           = "./modules/kafka-broker"
#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd.argocd_namespace
#   target_revision  = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     strimzi      = module.strimzi.id
#   }
# }
# module "cp-schema-registry" {
#   source           = "./modules/cp-schema-registry"
#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd.argocd_namespace
#   target_revision  = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     kafka-broker = module.kafka-broker.id
#   }
# }

# module "kafka-ui" {
#   source           = "./modules/kafka-ui"
#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd.argocd_namespace
#   target_revision  = local.target_revision
#   dependency_ids = {
#     traefik            = module.traefik.id
#     cert-manager       = module.cert-manager.id
#     kafka-broker       = module.kafka-broker.id
#     cp-schema-registry = module.cp-schema-registry.id
#   }
# }

# module "mysql" {
#   source                 = "./modules/mysql"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     oidc         = module.oidc.id
#   }
# }

# module "pinot" {
#   source                 = "./modules/pinot"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision

#   storage = {
#     bucket_name       = "pinot"
#     endpoint          = module.minio.cluster_dns
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     oidc         = module.oidc.id
#     minio        = module.minio.id
#   }
# }

# module "trino" {
#   source                 = "./modules/trino"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   pinot_dns              = module.pinot.cluster_dns
#   storage = {
#     bucket_name       = "trino"
#     endpoint          = module.minio.cluster_dns
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   database = {
#     user     = module.postgresql.credentials.user
#     password = module.postgresql.credentials.password
#     database = "curated"
#     service  = module.postgresql.cluster_ip
#   }
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     oidc         = module.oidc.id
#     minio        = module.minio.id
#     postgresql   = module.postgresql.id
#   }
# }

# module "mlflow" {
#   source                 = "./modules/mlflow"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   oidc                   = module.oidc.oidc
#   storage = {
#     bucket_name       = "mlflow"
#     endpoint          = module.minio.cluster_dns
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   database = {
#     user     = module.postgresql.credentials.user
#     password = module.postgresql.credentials.password
#     database = "mlflow"
#     service  = module.postgresql.cluster_ip
#   }
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     oidc         = module.oidc.id
#     minio        = module.minio.id
#     postgresql   = module.postgresql.id
#   }
# }

# module "ray" {
#   source           = "./modules/ray"
#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd.argocd_namespace
#   target_revision  = local.target_revision
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     minio        = module.minio.id
#     postgresql   = module.postgresql.id
#   }
# }

# module "jupyterhub" {
#   source                 = "./modules/jupyterhub"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   oidc                   = module.oidc.oidc
#   storage = {
#     bucket_name       = "jupyterhub"
#     endpoint          = module.minio.cluster_dns
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   database = {
#     user     = module.postgresql.credentials.user
#     password = module.postgresql.credentials.password
#     database = "jupyterhub"
#     service  = module.postgresql.cluster_ip
#   }
#   mlflow = {
#     cluster_ip = module.mlflow.cluster_ip
#   }
#   # ray = {
#   #   endpoint = module.ray.endpoint
#   # }
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     oidc         = module.oidc.id
#     minio        = module.minio.id
#     postgresql   = module.postgresql.id
#     mlflow       = module.mlflow.id
#   }
# }

# module "airflow" {
#   source                 = "./modules/airflow"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   oidc                   = module.oidc.oidc
#   fernetKey              = local.airflow_fernetKey
#   storage = {
#     bucket_name       = "airflow"
#     endpoint          = module.minio.cluster_dns
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   database = {
#     user     = module.postgresql.credentials.user
#     password = module.postgresql.credentials.password
#     database = "airflow"
#     service  = module.postgresql.cluster_dns
#   }
#   mlflow = {
#     endpoint = module.mlflow.cluster_dns
#   }
#   # ray = {
#   #   endpoint = module.ray.endpoint
#   # }
#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     oidc         = module.oidc.id
#     minio        = module.minio.id
#     mlflow       = module.mlflow.id
#     postgresql   = module.postgresql.id
#   }
#   depends_on = [module.traefik,
#     module.cert-manager,
#     module.oidc,
#     module.minio,
#     module.argocd,
#     module.postgresql,
#     module.mlflow,
#   ]
# }

# module "gitlab" {
#   source = "./modules/gitlab"

#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd.argocd_namespace

#   enable_service_monitor = local.enable_service_monitor

#   oidc = module.oidc.oidc

#   metrics_storage = {
#     bucket_name       = "registry"
#     endpoint          = module.minio.endpoint
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }

#   dependency_ids = {
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     oidc         = module.oidc.id
#     minio        = module.minio.id
#     postgresql   = module.postgresql.id
#   }

#   depends_on = [
#     module.traefik,
#     module.cert-manager,
#     module.oidc,
#     module.minio,
#     module.postgresql,
#     module.metallb
#   ]
# }
