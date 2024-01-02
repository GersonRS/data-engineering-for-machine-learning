locals {
  mlflow = var.mlflow != null ? base64encode("http://${var.mlflow.endpoint}:5000/?__extra__=%7B%7D") : base64encode("http://localhost:5000")
  secret = [
    {
      envName : "conn_minio_s3"
      secretName : "airflow-airflow-connections"
      secretKey : "AIRFLOW_CONN_MINIO_S3"
    },
    {
      envName : "conn_kubernetes"
      secretName : "airflow-airflow-connections"
      secretKey : "AIRFLOW_CONN_KUBERNETES"
    },
    {
      envName : "conn_curated"
      secretName : "airflow-airflow-connections"
      secretKey : "AIRFLOW_CONN_POSTEGRES_CURATED"
    },
    {
      envName : "conn_feature_store"
      secretName : "airflow-airflow-connections"
      secretKey : "AIRFLOW_CONN_POSTEGRES_FEATURE_STORE"
    },
    {
      envName : "conn_data"
      secretName : "airflow-airflow-connections"
      secretKey : "AIRFLOW_CONN_POSTEGRES_DATA"
    }
  ]
  helm_values = [{
    airflow = {
      fernetKey = "${var.fernetKey}"
      images = {
        airflow = {
          repository = "gersonrs/airflow"
          tag        = "latest"
        }
      }
      volumes = [
        {
          name = "airflow-airflow-connections"
          configMap = {
            name = "airflow-airflow-connections"
          }
        }
      ]
      executor                     = "KubernetesExecutor"
      webserverSecretKeySecretName = "my-webserver-secret"
      createUserJob = {
        useHelmHooks   = false
        applyCustomEnv = false
        jobAnnotations = {
          "argocd.argoproj.io/hook" : "Sync"
        }
      }
      migrateDatabaseJob = {
        useHelmHooks   = false
        applyCustomEnv = false
        jobAnnotations = {
          "argocd.argoproj.io/hook" : "Sync"
        }
      }
      # defaultUser = {
      #   enabled = false
      # }
      ingress = {
        enabled = true
        web = {
          enabled = true
          annotations = {
            "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
            "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
            "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
            "traefik.ingress.kubernetes.io/router.tls"         = "true"
            "ingress.kubernetes.io/ssl-redirect"               = "true"
            "kubernetes.io/ingress.allow-http"                 = "false"
          }
          hosts = [{
            name = "airflow.apps.${var.cluster_name}.${var.base_domain}"
            tls = {
              enabled    = true
              secretName = "airflow-tls-ingress"
            }
          }]
          ingressClassName = "traefik"
        }
      }
      pgbouncer = {
        enabled = true
      }
      data = {
        metadataSecretName = "airflow-metadata-secret"
      }
      postgresql = {
        enabled = false
      }
      triggerer = {
        persistence = {
          enabled = false
          size    = "10Gi"
        }
      }
      logs = {
        persistence = {
          enabled          = false
          size             = "10Gi"
          storageClassName = "standard"
        }
      }
      dags = {
        gitSync = {
          enabled      = true
          repo         = "git@github.com:GersonRS/airflow-dags.git"
          branch       = "${var.target_revision}"
          rev          = "HEAD"
          depth        = 1
          maxFailures  = 1
          subPath      = "dags"
          sshKeySecret = "airflow-ssh-secret"
          knownHosts   = "|-\n|1|yutcXh9HhbK6KCouq3xMQ38B9ns=|V9zQ39gzVxSZ75WU78CGJiVKCOk= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=\n|1|7ww9iNXn8d1jtXlaDjt+fYpsRi0=|vfHsTzw+QATWkCKD7kgG2jhu/1w= ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
        }
      }
      env = [
        {
          name  = "MLFLOW_TRACKING_URI"
          value = var.mlflow != null ? "http://${var.mlflow.endpoint}:5000" : "http://localhost:5000"
        },
        {
          name  = "MLFLOW_S3_ENDPOINT_URL"
          value = "http://${var.storage.endpoint}:9000"
        },
        {
          name  = "AWS_ENDPOINT"
          value = "http://${var.storage.endpoint}:9000"
        },
        {
          name  = "AWS_ACCESS_KEY_ID"
          value = "${var.storage.access_key}"
        },
        {
          name  = "AWS_SECRET_ACCESS_KEY"
          value = "${var.storage.secret_access_key}"
        },
        {
          name  = "AWS_REGION"
          value = "eu-west-1"
        },
        {
          name  = "AWS_ALLOW_HTTP"
          value = "true"
        },
        {
          name  = "AWS_S3_ALLOW_UNSAFE_RENAME"
          value = "true"
        },
        {
          name  = "GIT_PYTHON_REFRESH"
          value = "quiet"
        },
      ]
      secret = local.secret
      extraSecrets = {
        airflow-metadata-secret = {
          data = "connection: ${base64encode("postgresql://${var.database.user}:${var.database.password}@${var.database.endpoint}:5432/${var.database.database}")}"
        }
        my-webserver-secret = {
          data = "webserver-secret-key: ${base64encode(resource.random_password.airflow_webserver_secret_key.result)}"
        }
        airflow-airflow-connections = {
          data = <<-EOT
            AIRFLOW_CONN_KUBERNETES: ${base64encode("kubernetes:///?__extra__=%7B%22in_cluster%22%3A+true%2C+%22disable_verify_ssl%22%3A+false%2C+%22disable_tcp_keepalive%22%3A+false%7D")}
            AIRFLOW_CONN_MINIO_S3: ${base64encode("aws:///?region_name=eu-west-1&aws_access_key_id=${var.storage.access_key}&aws_secret_access_key=${var.storage.secret_access_key}&endpoint_url=http://${var.storage.endpoint}:9000")}
            AIRFLOW_CONN_POSTEGRES_CURATED: ${base64encode("postgresql://${var.database.user}:${var.database.password}@${var.database.endpoint}:5432/curated")}
            AIRFLOW_CONN_POSTEGRES_DATA: ${base64encode("postgresql://${var.database.user}:${var.database.password}@${var.database.endpoint}:5432/data")}
            AIRFLOW_CONN_POSTEGRES_FEATURE_STORE: ${base64encode("postgresql://${var.database.user}:${var.database.password}@${var.database.endpoint}:5432/feature_store")}
            AIRFLOW_CONN_MLFLOW: ${local.mlflow}
          EOT
        }
      }
      extraEnv = <<-EOT
        - name: AIRFLOW__LOGGING__REMOTE_LOGGING
          value: "True"
        - name: AIRFLOW__CORE__REMOTE_LOGGING
          value: "True"
        - name: AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER
          value: "s3://airflow/logs"
        - name: AIRFLOW__CORE__REMOTE_BASE_LOG_FOLDER
          value: "s3://airflow/logs"
        - name: AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID
          value: "conn_minio_s3"
        - name: AIRFLOW__CORE__REMOTE_LOG_CONN_ID
          value: "conn_minio_s3"
        - name: AIRFLOW__KUBERNETES__DELETE_WORKER_PODS
          value: "True"
        - name: AIRFLOW__CORE__ALLOWED_DESERIALIZATION_CLASSES
          value: airflow\.* astro\.*
      EOT
      extraConfigMaps = {
        airflow-airflow-connections = {
          data = <<-EOT
            script.sh: |
              #!/usr/bin/env bash
              conn=$(airflow connections list)
              if [ "$conn" = "No data found" ]; then
                connections=$(env | grep '^conn_' | sort)
                echo $connections | tr " " "\n" > .env
                airflow connections import .env
              fi
          EOT
        }
      }
      webserver = {
        env = [
          {
            name  = "OAUTH2_METADATA_URL"
            value = "${var.oidc.issuer_url}/.well-known/openid-configuration"
          },
          {
            name  = "OAUTH2_SERVER_METADATA_URL"
            value = "${var.oidc.issuer_url}/.well-known/openid-configuration"
          }
        ]
        webserverConfig = <<-EOT
            import os
            import logging
            import jwt
            import requests

            from base64 import b64decode
            from cryptography.hazmat.primitives import serialization
            from tokenize import Exponent

            from airflow import configuration as conf
            from flask_appbuilder.security.manager import AUTH_OAUTH
            from airflow.www.security import AirflowSecurityManager

            from flask_appbuilder import expose
            from flask_appbuilder.security.views import AuthOAuthView

            basedir = os.path.abspath(os.path.dirname(__file__))
            log = logging.getLogger(__name__)

            SQLALCHEMY_CONN = os.environ['AIRFLOW__CORE__SQL_ALCHEMY_CONN']
            SQLALCHEMY_DATABASE_URI = os.environ['AIRFLOW__DATABASE__SQL_ALCHEMY_CONN']

            CSRF_ENABLED = True
            WTF_CSRF_ENABLED = True
            AUTH_TYPE = AUTH_OAUTH

            AUTH_ROLE_ADMIN = 'Admin'
            AUTH_ROLE_PUBLIC = 'Public'
            AUTH_USER_REGISTRATION = True
            #Do not disable this in production
            OIDC_COOKIE_SECURE = False
            AUTH_ROLES_SYNC_AT_LOGIN = True
            AUTH_USER_REGISTRATION_ROLE = 'User'
            AUTH_ROLES_MAPPING = {
              "airflow_admin": ["Admin"],
              "modern-devops-stack-admins": ["Admin"],
              "airflow_op": ["Op"],
              "airflow_user": ["User"],
              "airflow_viewer": ["Viewer"],
              "airflow_public": ["Public"],
            }

            PROVIDER_NAME = 'keycloak'
            CLIENT_ID = "${var.oidc.client_id}"

            OAUTH_PROVIDERS = [{
                'name': PROVIDER_NAME,
                'token_key':'access_token',
                'icon':'fa-address-card',
                'remote_app': {
                    'api_base_url': '${var.oidc.issuer_url}',
                    'access_token_url': '${var.oidc.token_url}',
                    'authorize_url': '${var.oidc.oauth_url}',
                    'userinfo_url': '${var.oidc.api_url}',
                    'server_metadata_url': '${var.oidc.issuer_url}/.well-known/openid-configuration',
                    'request_token_url': None,
                    'client_id': CLIENT_ID,
                    'client_secret': '${var.oidc.client_secret}',
                    'client_kwargs':{
                        'scope': 'email profile openid',
                        "verify": False
                    },
                }
            }]

            # req = requests.get('${var.oidc.issuer_url}', verify=False)
            # key_der_base64 = req.json()["public_key"]
            # key_der = b64decode(key_der_base64.encode())
            # public_key = serialization.load_der_public_key(key_der)

            # class CustomAuthRemoteUserView(AuthOAuthView):
            #     @expose("/logout/")
            #     def logout(self):
            #         """Delete access token before logging out."""
            #         return super().logout()

            # class CustomSecurityManager(AirflowSecurityManager):
            #     authoauthview = CustomAuthRemoteUserView

            #     def oauth_user_info(self, provider, response):
            #         if provider == PROVIDER_NAME:
            #             log.info("response: {}".format(response))
            #             token = response["access_token"]
            #             log.info("token: {}".format(token))
            #             me = jwt.decode(token, public_key, algorithms=['HS256', 'RS256'], audience=CLIENT_ID)
            #             log.info("me: {}".format(me))
            #             groups = me.get("realm_access", {}).get("roles")
            #             if groups is None or len(groups) < 1:
            #                 groups = ["airflow_public"]
            #             else:
            #                 groups = [str for str in groups if "airflow" in str]

            #             log.info("making userinfo")
            #             userinfo = {
            #                 "username": me.get("preferred_username"),
            #                 "email": me.get("email"),
            #                 "first_name": me.get("given_name"),
            #                 "last_name": me.get("family_name"),
            #                 "role_keys": groups,
            #             }

            #             log.info("user info: {0}".format(userinfo))
            #             return userinfo
            #         else:
            #             return {}

            # SECURITY_MANAGER_CLASS = CustomSecurityManager
        EOT
        extraInitContainers = [
          {
            image           = "apache/airflow:2.7.3"
            imagePullPolicy = "IfNotPresent"
            resources       = {}
            env = concat([
              for config in local.secret : {
                name = config.envName
                valueFrom = {
                  secretKeyRef = {
                    name = config.secretName
                    key  = config.secretKey
                  }
                }
              }
              ], [
              {
                name = "AIRFLOW__CORE__SQL_ALCHEMY_CONN"
                valueFrom = {
                  secretKeyRef = {
                    name = "airflow-metadata-secret"
                    key  = "connection"
                  }
                }
              },
              {
                name = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
                valueFrom = {
                  secretKeyRef = {
                    name = "airflow-metadata-secret"
                    key  = "connection"
                  }
                }
              },
              {
                name = "AIRFLOW_CONN_AIRFLOW_DB"
                valueFrom = {
                  secretKeyRef = {
                    name = "airflow-metadata-secret"
                    key  = "connection"
                  }
                }
              },
              {
                name = "AIRFLOW__WEBSERVER__SECRET_KEY"
                valueFrom = {
                  secretKeyRef = {
                    name = "my-webserver-secret"
                    key  = "webserver-secret-key"
                  }
                }
              },
              {
                name = "AIRFLOW__CORE__FERNET_KEY"
                valueFrom = {
                  secretKeyRef = {
                    name = "airflow-fernet-key"
                    key  = "fernet-key"
                  }
                }
              },
            ])
            name = "config-connections"
            args = [
              "bash",
              "/opt/airflow/script.sh"
            ]
            volumeMounts = [
              {
                name = "airflow-airflow-connections"
                mountPath : "/opt/airflow/script.sh"
                subPath : "script.sh"
                readOnly : true
              }
            ]
          }
        ]
      }
      # extraEnvFrom = <<-EOT
      #   - configMapRef:
      #       name: 'airflow-airflow-variables'
      #   - secretRef:
      #       name: 'airflow-airflow-connections'
      # EOT
    }
  }]
}
