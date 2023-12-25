locals {
  argocd_chart = {
    name       = "argo-cd"
    repository = "https://argoproj.github.io/argo-helm"
    version    = "5.45.3"
  }
  argocd_version = "v2.8.3"

  jwt_token_payload = {
    jti = random_uuid.jti.result
    iat = time_static.iat.unix
    iss = "argocd"
    nbf = time_static.iat.unix
    sub = "pipeline"
  }

  argocd_accounts_pipeline_tokens = jsonencode(
    [
      {
        id  = random_uuid.jti.result
        iat = time_static.iat.unix
      }
    ]
  )

  helm_values = [{
    argo-cd = {
      dex = {
        enabled = false
      }
      repoServer = {
        volumes = [
          {
            configMap = {
              name = "kustomized-helm-cm"
            }
            name = "kustomized-helm-volume"
          }
        ]
        extraContainers = [
          {
            name    = "kustomized-helm-cmp"
            command = ["/var/run/argocd/argocd-cmp-server"]
            # Note: Argo CD official image ships Helm and Kustomize. No need to build a custom image to use "kustomized-helm" plugin.
            image = "quay.io/argoproj/argocd:${local.argocd_version}"
            securityContext = {
              runAsNonRoot = true
              runAsUser    = 999
            }
            volumeMounts = [
              {
                mountPath = "/var/run/argocd"
                name      = "var-files"
              },
              {
                mountPath = "/home/argocd/cmp-server/plugins"
                name      = "plugins"
              },
              {
                mountPath = "/home/argocd/cmp-server/config/plugin.yaml"
                subPath   = "plugin.yaml"
                name      = "kustomized-helm-volume"
              }
            ]
          }
        ]
      }
      extraObjects = [
        {
          apiVersion = "v1"
          kind       = "ConfigMap"
          metadata = {
            name = "kustomized-helm-cm"
          }
          data = {
            "plugin.yaml" = <<-EOT
              apiVersion: argoproj.io/v1alpha1
              kind: ConfigManagementPlugin
              metadata:
                name: kustomized-helm
              spec:
                init:
                  command: ["/bin/sh", "-c"]
                  args: ["helm dependency build || true"]
                generate:
                  command: ["/bin/sh", "-c"]
                  args: ["echo \"$ARGOCD_ENV_HELM_VALUES\" | helm template . --name-template $ARGOCD_APP_NAME --namespace $ARGOCD_APP_NAMESPACE $ARGOCD_ENV_HELM_ARGS -f - --include-crds > all.yaml && kustomize build"]
            EOT
          }
        }
      ]
      server = {
        extraArgs = [
          "--insecure",
        ]
        config = {
          "admin.enabled"           = "true" # autogenerates password, see `argocd-initial-admin-secret`
          "accounts.pipeline"       = "apiKey"
          "resource.customizations" = <<-EOT
            argoproj.io/Application: # https://argo-cd.readthedocs.io/en/stable/operator-manual/health/#argocd-app
              health.lua: |
                hs = {}
                hs.status = "Progressing"
                hs.message = ""
                if obj.status ~= nil then
                  if obj.status.health ~= nil then
                    hs.status = obj.status.health.status
                    if obj.status.health.message ~= nil then
                      hs.message = obj.status.health.message
                    end
                  end
                end
                return hs
            networking.k8s.io/Ingress: # https://argo-cd.readthedocs.io/en/stable/faq/#why-is-my-application-stuck-in-progressing-state
              health.lua: |
                hs = {}
                hs.status = "Healthy"
                return hs
          EOT
        }
      }
      configs = {
        rbac = {
          scopes           = "[groups, cognito:groups, roles]"
          "policy.default" = ""
          "policy.csv"     = <<-EOT
                              g, pipeline, role:admin
                              g, argocd-admin, role:admin
                              g, modern-devops-stack-admins, role:admin
                              EOT
        }
        secret = {
          extra = {
            "accounts.pipeline.tokens" = "${replace(local.argocd_accounts_pipeline_tokens, "\\\"", "\"")}"
            "server.secretkey"         = "${replace(random_password.argocd_server_secretkey.result, "\\\"", "\"")}"
          }
        }
      }
    }
  }]
}
