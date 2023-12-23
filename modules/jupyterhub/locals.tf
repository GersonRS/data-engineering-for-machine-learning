locals {

  vars = {
    RAY_ADDRESS = var.ray != null ? "ray://${var.ray.endpoint}:10001" : null
  }
  helm_values = [{

    # client_id          = "${var.oidc.client_id}"
    # client_secret      = "${var.oidc.client_secret}"
    # oauth_callback_url = "https://jupyterhub.apps.${var.cluster_name}.${var.base_domain}/hub/oauth_callback"
    # authorize_url      = "${var.oidc.oauth_url}"
    # token_url          = "${var.oidc.token_url}"
    # userdata_url       = "${var.oidc.api_url}"

    # externalDatabase = {
    #   host     = "${var.database.service}"
    #   port     = 5432
    #   user     = "${var.database.user}"
    #   database = "${var.database.database}"
    #   password = "${var.database.password}"
    # }
    # postgresql = {
    #   enabled = false
    # }
    # singleuser = {
    #   image = {
    #     repository = "gersonrs/jupyter-base-notebook"
    #     tag : "latest"
    #   }
    #   extraEnvVars = merge({
    #     # MLFLOW_TRACKING_URI = "postgresql+psycopg2://${var.database.user}:${var.database.password}@${var.database.service}:5432/mlflow"

    #     MLFLOW_TRACKING_URI        = "http://${var.mlflow.cluster_ip}:5000"
    #     MLFLOW_S3_ENDPOINT_URL     = "http://${var.storage.endpoint}"
    #     AWS_ENDPOINT               = "http://${var.storage.endpoint}"
    #     AWS_ACCESS_KEY_ID          = "${var.storage.access_key}"
    #     AWS_SECRET_ACCESS_KEY      = "${var.storage.secret_access_key}"
    #     AWS_REGION                 = "eu-west-1",
    #     AWS_ALLOW_HTTP             = "true",
    #     AWS_S3_ALLOW_UNSAFE_RENAME = "true",
    #     },
    #     var.ray != null ? local.vars : null
    #   )
    #   # notebookDir: "/"
    # }
    # hub = {
    #   adminUser = "moderndevopsadmin"
    #   password  = "Yug4pcsjhFD55iHN6YZLrVGypPKhmwuF"
    # }
    # proxy = {
    #   ingress = {
    #     enabled = true
    #     ingressClassName : "traefik"
    #     hostname = "jupyterhub.apps.${var.cluster_name}.${var.base_domain}"
    #     annotations = {
    #       "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
    #       "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
    #       "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
    #       "traefik.ingress.kubernetes.io/router.tls"         = "true"
    #       "ingress.kubernetes.io/ssl-redirect"               = "true"
    #       "kubernetes.io/ingress.allow-http"                 = "false"
    #     }
    #     tls = true
    #   }
    # }
    proxy = {
      https = {
        enabled = true
      }
    }
    hub = {
      image = {
        name = "gersonrs/k8s-hub"
        tag  = "latest"
      }
      config = {
        GenericOAuthenticator = {
          client_id          = "${var.oidc.client_id}"
          client_secret      = "${var.oidc.client_secret}"
          oauth_callback_url = "https://jupyterhub.apps.${var.cluster_name}.${var.base_domain}/hub/oauth_callback"
          authorize_url      = "${var.oidc.oauth_url}"
          token_url          = "${var.oidc.token_url}"
          userdata_method    = "POST"
          userdata_url       = "${var.oidc.api_url}"
          login_service      = "keycloak"
          username_claim     = "email"
          scope              = ["openid", "email", "groups"]
          tls_verify         = false
          userdata_params = {
            state = "state"
          }
          # In order to use keycloak client's roles as authorization layer
          claim_groups_key = "groups"
          allowed_groups   = ["user", "modern-devops-stack-admins"]
          admin_groups     = ["admin", "modern-devops-stack-admins"]
        }
        JupyterHub = {
          authenticator_class = "generic-oauth"
        }
      }
    }
    singleuser = {
      image = {
        name = "quay.io/jupyter/all-spark-notebook"
        tag  = "latest"
      }
    }
    ingress = {
      enabled = true
      annotations = {
        "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
        "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
        "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
        "traefik.ingress.kubernetes.io/router.tls"         = "true"
        "ingress.kubernetes.io/ssl-redirect"               = "true"
        "kubernetes.io/ingress.allow-http"                 = "false"
      }
      ingressClassName = "traefik"
      hosts            = ["jupyterhub.apps.${var.base_domain}", "jupyterhub.apps.${var.cluster_name}.${var.base_domain}"]
      tls = [{
        hosts      = ["jupyterhub.apps.${var.cluster_name}.${var.base_domain}"]
        secretName = "jupyterhub-ingres-tls"
      }]
    }
  }]
}
