locals {
  helm_values = [{
    proxy = {
      https = {
        enabled = true
      }
    }
    hub = {
      extraEnv = {
        OAUTH_TLS_VERIFY = "0"
      }
      config = {
        GenericOAuthenticator = {
          login_service      = "keycloak"
          client_id          = "${var.oidc.client_id}"
          client_secret      = "${var.oidc.client_secret}"
          oauth_callback_url = "https://jupyterhub.apps.${var.cluster_name}.${var.base_domain}/hub/oauth_callback"
          authorize_url      = "${var.oidc.oauth_url}"
          token_url          = "${var.oidc.token_url}"
          userdata_url       = "${var.oidc.api_url}"
          username_key       = "preferred_username"
          scope              = ["openid", "email", "groups"]
          userdata_params    = { state = "state" }
          claim_groups_key   = "groups"
          allowed_groups     = ["user", "modern-devops-stack-admins"]
          admin_groups       = ["modern-devops-stack-admins"]
        }
        JupyterHub = {
          admin_access        = true
          authenticator_class = "generic-oauth"
        }
      }
    }
    debug = {
      enabled = true
    }
    singleuser = {
      image = {
        name = "quay.io/jupyter/all-spark-notebook"
        tag  = "latest"
      }
      storage = {
        homeMountPath = "/home/jovyan/work"
      }
      extraEnv = {
        DB_ENDPOINT                = "${var.database.endpoint}"
        DB_USER                    = "${var.database.user}"
        DB_PASSWORD                = "${var.database.password}"
        MLFLOW_TRACKING_URI        = var.mlflow != null ? "http://${var.mlflow.endpoint}:5000" : null
        MLFLOW_S3_ENDPOINT_URL     = "http://${var.storage.endpoint}"
        AWS_ENDPOINT               = "http://${var.storage.endpoint}"
        AWS_ACCESS_KEY_ID          = "${var.storage.access_key}"
        AWS_SECRET_ACCESS_KEY      = "${var.storage.secret_access_key}"
        AWS_REGION                 = "eu-west-1",
        AWS_ALLOW_HTTP             = "true",
        AWS_S3_ALLOW_UNSAFE_RENAME = "true",
        RAY_ADDRESS                = var.ray != null ? "ray://${var.ray.endpoint}:10001" : null
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
        hosts      = ["jupyterhub.apps.${var.base_domain}", "jupyterhub.apps.${var.cluster_name}.${var.base_domain}"]
        secretName = "jupyterhub-ingres-tls"
      }]
    }
  }]
}
