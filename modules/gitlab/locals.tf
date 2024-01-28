locals {
  rails = [{
    provider              = "AWS"
    region                = "us-east-1"
    aws_access_key_id     = "${var.metrics_storage.access_key}"
    aws_secret_access_key = "${var.metrics_storage.secret_access_key}"
    aws_signature_version = 4
    host                  = split(":", var.metrics_storage.endpoint)[0]
    endpoint              = "${var.metrics_storage.endpoint}"
    path_style            = true
  }]
  registry = [{
    s3 = {
      v4auth         = true
      regionendpoint = "${var.metrics_storage.endpoint}"
      pathstyle      = true
      region         = "us-east-1"
      bucket         = "registry"
      accesskey      = "${var.metrics_storage.access_key}"
      secretkey      = "${var.metrics_storage.secret_access_key}"
    }
  }]
  provider_name = "saml"
  provider = [{
    name = local.provider_name
    args = {
      assertion_consumer_service_url = "https://gitlab.apps.${var.cluster_name}.${var.base_domain}/users/auth/saml/callback"
      idp_cert_fingerprint           = var.oidc.fingerprint
      idp_sso_target_url             = "https://keycloak.apps.${var.cluster_name}.${var.base_domain}/realms/modern-gitops-stack/protocol/saml/clients/gitlab"
      issuer                         = "gitlab"
      name_identifier_format         = "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent"
      attribute_statements : { username : ["username"] }
    }
    label = "KEYCLOAK LOGIN"
  }]

  helm_values = [{
    gitlab = {
      global = {
        appConfig = {
          object_store = {
            enabled = true
            connection = {
              secret = "gitlab-rails-storage"
            }
          }
          omniauth = {
            enabled = true
            # autoSignInWithProvider = "${local.provider_name}"
            allowSingleSignOn     = [local.provider_name]
            blockAutoCreatedUsers = false
            autoLinkLdapUser      = false
            autoLinkSamlUser      = true
            autoLinkUser          = [local.provider_name]

            providers = [{
              secret = "gitlab-provider"
            }]
          }
        }
        ingress = {
          configureCertmanager = false
          class                = "traefik"
          provider             = "traefik"
          annotations = {
            "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
            "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
            "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
            "traefik.ingress.kubernetes.io/router.tls"         = "true"
            "ingress.kubernetes.io/ssl-redirect"               = "true"
            "kubernetes.io/ingress.allow-http"                 = "false"
          }
          tls = {
            enabled    = true
            secretName = "gitlab-ingress-tls"
          }
        }
        hosts = {
          domain     = "apps.${var.cluster_name}.${var.base_domain}"
          externalIP = replace(split(".", var.base_domain)[0], "-", ".")
        }
        minio = {
          enabled = false
        }
        rails = {
          bootsnap = {
            enabled = false
          }
        }
        shell = {
          port = 32022
        }
        registry = {
          bucket = "registry"
        }
      }
      certmanager = {
        install = false
      }
      nginx-ingress = {
        enabled = false
      }
      prometheus = {
        install = false
      }
      gitlab-runner = {
        install = false
        runners = {
          privileged = true
        }
      }
      gitlab = {
        webservice = {
          minReplicas = 1
          maxReplicas = 1
        }
        sidekiq = {
          minReplicas = 1
          maxReplicas = 1
        }
        gitlab-shell = {
          minReplicas = 1
          maxReplicas = 1
          service = {
            type     = "NodePort"
            nodePort = 32022
          }
        }
      }
      registry = {
        storage = {
          secret = "gitlab-registry-storage"
          key    = "config"
        }
        hpa = {
          minReplicas = 1
          maxReplicas = 1
        }
      }
    }
  }]
}
