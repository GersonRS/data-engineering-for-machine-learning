module "kind" {
  source             = "./modules/kind"
  cluster_name       = local.cluster_name
  kubernetes_version = local.kubernetes_version
}

module "metallb" {
  source = "./modules/metallb"
  subnet = module.kind.kind_subnet
}

module "argocd_bootstrap" {
  source     = "./modules/argocd_bootstrap"
  depends_on = [module.kind]
}

module "traefik" {
  source                 = "./modules/traefik/kind"
  cluster_name           = local.cluster_name
  base_domain            = "172-18-0-100.nip.io"
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  dependency_ids = {
    argocd = module.argocd_bootstrap.id
  }
}

module "cert-manager" {
  source                 = "./modules/cert-manager/self-signed"
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  dependency_ids = {
    argocd = module.argocd_bootstrap.id
  }
}

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
  }
}

module "minio" {
  source                 = "./modules/minio"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  oidc                   = module.oidc.oidc
  target_revision        = local.target_revision
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
    oidc         = module.oidc.id
  }
}

# module "loki-stack" {
#   source           = "./modules/loki-stack/kind"
#   argocd_namespace = module.argocd_bootstrap.argocd_namespace
#   logs_storage = {
#     bucket_name = "loki-bucket"
#     endpoint    = module.minio.cluster_dns
#     access_key  = module.minio.minio_root_user_credentials.username
#     secret_key  = module.minio.minio_root_user_credentials.password
#   }
#   target_revision = local.target_revision
#   dependency_ids = {
#     minio = module.minio.id
#   }
# }

# module "thanos" {
#   source           = "./modules/thanos/kind"
#   cluster_name     = local.cluster_name
#   base_domain      = local.base_domain
#   cluster_issuer   = local.cluster_issuer
#   argocd_namespace = module.argocd_bootstrap.argocd_namespace
#   metrics_storage = {
#     bucket_name = "thanos-bucket"
#     endpoint    = module.minio.cluster_dns
#     access_key  = module.minio.minio_root_user_credentials.username
#     secret_key  = module.minio.minio_root_user_credentials.password
#   }
#   thanos = {
#     oidc = module.oidc.oidc
#   }
#   target_revision = local.target_revision
#   dependency_ids = {
#     argocd       = module.argocd_bootstrap.id
#     traefik      = module.traefik.id
#     cert-manager = module.cert-manager.id
#     minio        = module.minio.id
#     keycloak     = module.keycloak.id
#     oidc         = module.oidc.id
#   }
# }

module "kube-prometheus-stack" {
  source           = "./modules/kube-prometheus-stack/kind"
  cluster_name     = local.cluster_name
  base_domain      = local.base_domain
  cluster_issuer   = local.cluster_issuer
  argocd_namespace = module.argocd_bootstrap.argocd_namespace
  metrics_storage = {
    bucket_name = "thanos-bucket"
    endpoint    = module.minio.cluster_dns
    access_key  = module.minio.minio_root_user_credentials.username
    secret_key  = module.minio.minio_root_user_credentials.password
  }
  prometheus = {
    oidc = module.oidc.oidc
  }
  alertmanager = {
    oidc = module.oidc.oidc
  }
  grafana = {
    oidc = module.oidc.oidc
  }
  target_revision = local.target_revision
  dependency_ids = {
    traefik      = module.traefik.id
    cert-manager = module.cert-manager.id
    minio        = module.minio.id
    oidc         = module.oidc.id
  }
}

module "reflector" {
  source                 = "./modules/reflector"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
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
    traefik = module.traefik.id
    argocd  = module.argocd_bootstrap.id
  }
}

module "spark" {
  source                 = "./modules/spark"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  dependency_ids = {
    argocd = module.argocd_bootstrap.id
  }
}

# module "strimzi" {
#   source                 = "./modules/strimzi"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd_bootstrap.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   dependency_ids = {
#     argocd = module.argocd_bootstrap.id
#   }
# }

# module "kafka" {
#   source                 = "./modules/kafka"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd_bootstrap.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   argocd_project         = module.strimzi.argocd_project_name
#   dependency_ids = {
#     argocd  = module.argocd_bootstrap.id
#     traefik = module.traefik.id
#     strimzi = module.strimzi.id
#   }
# }

# module "cp-schema-registry" {
#   source                 = "./modules/cp-schema-registry"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd_bootstrap.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   argocd_project         = module.strimzi.argocd_project_name
#   kafka_broker_name      = module.kafka.broker_name
#   dependency_ids = {
#     argocd = module.argocd_bootstrap.id
#     kafka  = module.kafka.id
#   }
# }

# module "kafka-ui" {
#   source                 = "./modules/kafka-ui"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd_bootstrap.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   kafka_broker_name      = module.kafka.broker_name
#   dependency_ids = {
#     argocd             = module.argocd_bootstrap.id
#     kafka              = module.kafka.id
#     cp-schema-registry = module.cp-schema-registry.id
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
#     argocd  = module.argocd_bootstrap.id
#     traefik = module.traefik.id
#   }
# }

module "vault" {
  source                 = "./modules/vault"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
  dependency_ids = {
    argocd  = module.argocd_bootstrap.id
    traefik = module.traefik.id
  }
}

# module "pinot" {
#   source                 = "./modules/pinot"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd_bootstrap.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   storage = {
#     bucket_name       = "pinot"
#     endpoint          = module.minio.cluster_dns
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   dependency_ids = {
#     argocd  = module.argocd_bootstrap.id
#     traefik = module.traefik.id
#     oidc    = module.oidc.id
#     minio   = module.minio.id
#   }
# }

# module "trino" {
#   source                 = "./modules/trino"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd_bootstrap.argocd_namespace
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
#     argocd     = module.argocd_bootstrap.id
#     traefik    = module.traefik.id
#     oidc       = module.oidc.id
#     minio      = module.minio.id
#     postgresql = module.postgresql.id
#     pinot      = module.pinot.id
#   }
# }

module "mlflow" {
  source                 = "./modules/mlflow"
  cluster_name           = local.cluster_name
  base_domain            = local.base_domain
  cluster_issuer         = local.cluster_issuer
  argocd_namespace       = module.argocd_bootstrap.argocd_namespace
  enable_service_monitor = local.enable_service_monitor
  target_revision        = local.target_revision
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
    service  = module.postgresql.cluster_dns
  }
  dependency_ids = {
    argocd     = module.argocd_bootstrap.id
    traefik    = module.traefik.id
    minio      = module.minio.id
    postgresql = module.postgresql.id
  }
}

# module "ray" {
#   source                 = "./modules/ray"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd_bootstrap.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   dependency_ids = {
#     argocd  = module.argocd_bootstrap.id
#     traefik = module.traefik.id
#   }
# }

# module "jupyterhub" {
#   source                 = "./modules/jupyterhub"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd_bootstrap.argocd_namespace
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
#     endpoint = module.postgresql.cluster_dns
#   }
#   mlflow = {
#     endpoint = module.mlflow.cluster_dns
#   }
#   # ray = {
#   #   endpoint = module.ray.cluster_dns
#   # }
#   dependency_ids = {
#     argocd     = module.argocd_bootstrap.id
#     traefik    = module.traefik.id
#     oidc       = module.oidc.id
#     minio      = module.minio.id
#     postgresql = module.postgresql.id
#     mlflow     = module.mlflow.id
#     # ray        = module.ray.id
#   }
# }

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
    endpoint          = module.minio.cluster_dns
    access_key        = module.minio.minio_root_user_credentials.username
    secret_access_key = module.minio.minio_root_user_credentials.password
  }
  database = {
    user     = module.postgresql.credentials.user
    password = module.postgresql.credentials.password
    database = "airflow"
    endpoint = module.postgresql.cluster_dns
  }
  mlflow = {
    endpoint = module.mlflow.cluster_dns
  }
  # ray = {
  #   endpoint = module.ray.cluster_dns
  # }
  dependency_ids = {
    argocd     = module.argocd_bootstrap.id
    traefik    = module.traefik.id
    oidc       = module.oidc.id
    minio      = module.minio.id
    postgresql = module.postgresql.id
    mlflow     = module.mlflow.id
    # ray        = module.ray.id
  }
}

# module "gitlab" {
#   source                 = "./modules/gitlab"
#   cluster_name           = local.cluster_name
#   base_domain            = local.base_domain
#   cluster_issuer         = local.cluster_issuer
#   argocd_namespace       = module.argocd_bootstrap.argocd_namespace
#   enable_service_monitor = local.enable_service_monitor
#   target_revision        = local.target_revision
#   oidc                   = module.oidc.oidc
#   metrics_storage = {
#     bucket_name       = "registry"
#     endpoint          = module.minio.cluster_dns
#     access_key        = module.minio.minio_root_user_credentials.username
#     secret_access_key = module.minio.minio_root_user_credentials.password
#   }
#   dependency_ids = {
#     argocd     = module.argocd_bootstrap.id
#     traefik    = module.traefik.id
#     oidc       = module.oidc.id
#     minio      = module.minio.id
#     postgresql = module.postgresql.id
#   }
# }

module "argocd" {
  source                   = "./modules/argocd"
  base_domain              = local.base_domain
  cluster_name             = local.cluster_name
  cluster_issuer           = local.cluster_issuer
  server_secretkey         = module.argocd_bootstrap.argocd_server_secretkey
  accounts_pipeline_tokens = module.argocd_bootstrap.argocd_accounts_pipeline_tokens
  admin_enabled            = false
  exec_enabled             = true
  oidc = {
    name         = "OIDC"
    issuer       = module.oidc.oidc.issuer_url
    clientID     = module.oidc.oidc.client_id
    clientSecret = module.oidc.oidc.client_secret
    requestedIDTokenClaims = {
      groups = {
        essential = true
      }
    }
  }
  rbac = {
    policy_csv = <<-EOT
      g, pipeline, role:admin
      g, modern-devops-stack-admins, role:admin
    EOT
  }
  target_revision = local.target_revision
  dependency_ids = {
    traefik               = module.traefik.id
    cert-manager          = module.cert-manager.id
    oidc                  = module.oidc.id
    kube-prometheus-stack = module.kube-prometheus-stack.id
    airflow               = module.airflow.id
    # jupyterhub            = module.jupyterhub.id
  }
}


# module "kubectl" {
#   source = "magnolia-sre/kubectl-cmd/kubernetes"

#   app          = "vault"
#   cluster-name = "mycluster"
#   credentials = {
#     kubeconfig-path : "${path.root}/kind-config"
#   }
#   cmds = [<<-EOT
#     sleep 15
#     kubens management
#     kubectl exec vault-0 -n management -- vault operator init \
#     -key-shares=1 \
#     -key-threshold=1 \
#     -format=json > cluster-keys.json
#     jq -r '.unseal_keys_b64[]' cluster-keys.json
#     VAULT_UNSEAL_KEY=$(jq -r '.unseal_keys_b64[]' cluster-keys.json)
#     sleep 3
#     kubectl exec vault-0 -n management -- vault operator unseal $VAULT_UNSEAL_KEY
#     sleep 3
#     kubectl exec -ti vault-1 -n management -- vault operator raft join http://vault-0.vault-internal:8200
#     sleep 3
#     kubectl exec -ti vault-2 -n management -- vault operator raft join http://vault-0.vault-internal:8200
#     sleep 3
#     kubectl exec -ti vault-1 -n management -- vault operator unseal $VAULT_UNSEAL_KEY
#     sleep 3
#     kubectl exec -ti vault-2 -n management -- vault operator unseal $VAULT_UNSEAL_KEY
#     EOT
#   ]
#   depends_on = [module.vault]
# }
