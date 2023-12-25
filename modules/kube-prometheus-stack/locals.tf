locals {
  oauth2_proxy_image       = "quay.io/oauth2-proxy/oauth2-proxy:v7.5.0"
  curl_wait_for_oidc_image = "curlimages/curl:8.3.0"

  ingress_annotations = {
    "cert-manager.io/cluster-issuer"                   = "${var.cluster_issuer}"
    "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
    "traefik.ingress.kubernetes.io/router.middlewares" = "traefik-withclustername@kubernetescrd"
    "traefik.ingress.kubernetes.io/router.tls"         = "true"
    "ingress.kubernetes.io/ssl-redirect"               = "true"
    "kubernetes.io/ingress.allow-http"                 = "false"
  }

  grafana_defaults = {
    enabled                  = true
    additional_data_sources  = false
    generic_oauth_extra_args = {}
    domain                   = "grafana.apps.${var.cluster_name}.${var.base_domain}"
    admin_password           = random_password.grafana_admin_password.result
  }

  grafana = merge(
    local.grafana_defaults,
    var.grafana,
  )

  prometheus_defaults = {
    enabled = true
    domain  = "prometheus.apps.${var.cluster_name}.${var.base_domain}"
  }

  prometheus = merge(
    local.prometheus_defaults,
    var.prometheus,
  )

  alertmanager_defaults = {
    enabled            = true
    domain             = "alertmanager.apps.${var.cluster_name}.${var.base_domain}"
    deadmanssnitch_url = null
    slack_routes       = []
  }

  alertmanager = merge(
    local.alertmanager_defaults,
    var.alertmanager,
  )

  alertmanager_receivers = flatten([
    [{
      name = "devnull"
    }],
    local.alertmanager.deadmanssnitch_url != null ? [{
      name = "deadmanssnitch"
      webhook_configs = [{
        url           = local.alertmanager.deadmanssnitch_url
        send_resolved = false
      }]
    }] : [],
    [for item in local.alertmanager.slack_routes : {
      name = item["name"]
      slack_configs = [{
        channel       = item["channel"]
        api_url       = item["api_url"]
        send_resolved = true
        icon_url      = "https://avatars3.githubusercontent.com/u/3380462"
        title         = "{{ template \"slack.title\" . }}"
        text          = "{{ template \"slack.text\" . }}"
      }]
    }],
  ])

  alertmanager_routes = {
    group_by = ["alertname"]
    receiver = "devnull"
    routes = flatten([
      local.alertmanager.deadmanssnitch_url != null ? [{ matchers = ["alertname=\"Watchdog\""], receiver = "deadmanssnitch", repeat_interval = "2m" }] : [],
      [for item in local.alertmanager.slack_routes : {
        matchers = item["matchers"]
        receiver = item["name"]
        continue = lookup(item, "continue", false)
      }]
    ])
  }

  alertmanager_template_files = length(local.alertmanager.slack_routes) > 0 ? {
    "slack.tmpl" = <<-EOT
      {{ define "slack.title" -}}
        [{{ .Status | toUpper }}
        {{ if eq .Status "firing" }}:{{ .Alerts.Firing | len }}{{- end -}}
        ] {{ .CommonLabels.alertname }}
      {{ end }}
      {{ define "slack.text" -}}
      {{ range .Alerts }}
        *Alert:* {{ .Annotations.summary }} - `{{ .Labels.severity }}`
        {{- if .Annotations.description }}
        *Severity:* `{{ .Labels.severity }}`
        *Description:* {{ .Annotations.description }}
        {{- end }}
        *Graph:* <{{ .GeneratorURL }}|:chart_with_upwards_trend:>
        *Labels:*
          {{ range .Labels.SortedPairs }} - *{{ .Name }}:* `{{ .Value }}`
          {{ end }}
      {{ end }}
      {{ end }}
    EOT
  } : {}

  helm_values = [{
    kube-prometheus-stack = {
      alertmanager = merge(local.alertmanager.enabled ? {
        alertmanagerSpec = {
          initContainers = [
            {
              name  = "wait-for-oidc"
              image = local.curl_wait_for_oidc_image
              command = [
                "/bin/sh",
                "-c",
              ]
              args = [
                <<-EOT
                until curl -skL -w "%%{http_code}\\n" "${replace(local.alertmanager.oidc.api_url, "\"", "\\\"")}" -o /dev/null | grep -vq "^\(000\|404\)$"; do echo "waiting for oidc at ${replace(local.alertmanager.oidc.api_url, "\"", "\\\"")}"; sleep 2; done
              EOT
              ]
            },
          ]
          containers = [
            {
              image = local.oauth2_proxy_image
              name  = "alertmanager-proxy"
              ports = [
                {
                  name          = "proxy"
                  containerPort = 9095
                },
              ]
              args = concat([
                "--http-address=0.0.0.0:9095",
                "--upstream=http://localhost:9093",
                "--provider=oidc",
                "--oidc-issuer-url=${replace(local.alertmanager.oidc.issuer_url, "\"", "\\\"")}",
                "--client-id=${replace(local.alertmanager.oidc.client_id, "\"", "\\\"")}",
                "--client-secret=${replace(local.alertmanager.oidc.client_secret, "\"", "\\\"")}",
                "--cookie-secure=false",
                "--cookie-secret=${replace(random_password.oauth2_cookie_secret.result, "\"", "\\\"")}",
                "--email-domain=*",
                "--redirect-url=https://${local.alertmanager.domain}/oauth2/callback",
              ], local.alertmanager.oidc.oauth2_proxy_extra_args)
            },
          ]
        }
        ingress = {
          enabled     = true
          annotations = local.ingress_annotations
          servicePort = "9095"
          hosts = [
            "${local.alertmanager.domain}",
            "alertmanager.apps.${var.base_domain}"
          ]
          tls = [
            {
              secretName = "alertmanager-tls"
              hosts = [
                "${local.alertmanager.domain}",
                "alertmanager.apps.${var.base_domain}",
              ]
            },
          ]
        }
        service = {
          additionalPorts = [
            {
              name       = "proxy"
              port       = 9095
              targetPort = 9095
            },
          ]
        }
        config = {
          route     = local.alertmanager_routes
          receivers = local.alertmanager_receivers
        }
        templateFiles = local.alertmanager_template_files
        } : null, {
        enabled = local.alertmanager.enabled
      })
      grafana = merge(local.grafana.enabled ? {
        adminPassword = "${replace(local.grafana.admin_password, "\"", "\\\"")}"
        "grafana.ini" = {
          "auth.generic_oauth" = merge({
            enabled                  = true
            allow_sign_up            = true
            client_id                = "${replace(local.grafana.oidc.client_id, "\"", "\\\"")}"
            client_secret            = "${replace(local.grafana.oidc.client_secret, "\"", "\\\"")}"
            scopes                   = "openid profile email"
            auth_url                 = "${replace(local.grafana.oidc.oauth_url, "\"", "\\\"")}"
            token_url                = "${replace(local.grafana.oidc.token_url, "\"", "\\\"")}"
            api_url                  = "${replace(local.grafana.oidc.api_url, "\"", "\\\"")}"
            tls_skip_verify_insecure = var.cluster_issuer == "ca-issuer" || var.cluster_issuer == "letsencrypt-staging"
          }, local.grafana.generic_oauth_extra_args)
          users = {
            auto_assign_org_role = "Editor"
          }
          server = {
            domain   = "${local.grafana.domain}"
            root_url = "https://%(domain)s" # TODO check this
          }
          dataproxy = {
            timeout = var.dataproxy_timeout
          }
        }
        sidecar = {
          datasources = {
            defaultDatasourceEnabled = false
          }
        }
        additionalDataSources = [merge(var.metrics_storage_main != null ? {
          name = "Thanos"
          url  = "http://thanos-query-frontend.thanos:9090"
          } : {
          name = "Prometheus"
          url  = "http://kube-prometheus-stack-prometheus:9090"
          }, {
          type      = "prometheus"
          access    = "proxy"
          isDefault = true
          jsonData = {
            tlsAuth           = false
            tlsAuthWithCACert = false
            oauthPassThru     = true
          }
          }
        )]
        ingress = {
          enabled     = true
          annotations = local.ingress_annotations
          hosts = [
            "${local.grafana.domain}",
            "grafana.apps.${var.base_domain}",
          ]
          tls = [
            {
              secretName = "grafana-tls"
              hosts = [
                "${local.grafana.domain}",
                "grafana.apps.${var.base_domain}",
              ]
            },
          ]
        }
        } : null,
        merge((!local.grafana.enabled && local.grafana.additional_data_sources) ? {
          forceDeployDashboards  = true
          forceDeployDatasources = true
          sidecar = {
            datasources = {
              defaultDatasourceEnabled = false
            }
          }
          additionalDataSources = [merge(var.metrics_storage_main != null ? {
            name = "Thanos"
            url  = "http://thanos-query.thanos:9090"
            } : {
            # Note that since this is for the the Grafana module deployed inside it's
            # own namespace, we need to have the reference to the namespace in the URL.
            name = "Prometheus"
            url  = "http://kube-prometheus-stack-prometheus.kube-prometheus-stack:9090"
            }, {
            type      = "prometheus"
            access    = "proxy"
            isDefault = true
            jsonData = {
              tlsAuth           = false
              tlsAuthWithCACert = false
              oauthPassThru     = true
            }
            }
          )]
          } : null, {
          enabled = local.grafana.enabled
        })
      )
      prometheus = merge(local.prometheus.enabled ? {
        ingress = {
          enabled     = true
          annotations = local.ingress_annotations
          servicePort = "9091"
          hosts = [
            "${local.prometheus.domain}",
            "prometheus.apps.${var.base_domain}",
          ]
          tls = [
            {
              secretName = "prometheus-tls"
              hosts = [
                "${local.prometheus.domain}",
                "prometheus.apps.${var.base_domain}",
              ]
            },
          ]
        }
        prometheusSpec = merge({
          initContainers = [
            {
              name  = "wait-for-oidc"
              image = local.curl_wait_for_oidc_image
              command = [
                "/bin/sh",
                "-c",
              ]
              args = [
                <<-EOT
                until curl -skL -w "%%{http_code}\\n" "${replace(local.prometheus.oidc.api_url, "\"", "\\\"")}" -o /dev/null | grep -vq "^\(000\|404\)$"; do echo "waiting for oidc at ${replace(local.prometheus.oidc.api_url, "\"", "\\\"")}"; sleep 2; done
              EOT
              ]
            },
          ]
          containers = [
            {
              args = concat([
                "--http-address=0.0.0.0:9091",
                "--upstream=http://localhost:9090",
                "--provider=oidc",
                "--oidc-issuer-url=${replace(local.prometheus.oidc.issuer_url, "\"", "\\\"")}",
                "--client-id=${replace(local.prometheus.oidc.client_id, "\"", "\\\"")}",
                "--client-secret=${replace(local.prometheus.oidc.client_secret, "\"", "\\\"")}",
                "--cookie-secure=false",
                "--cookie-secret=${replace(random_password.oauth2_cookie_secret.result, "\"", "\\\"")}",
                "--email-domain=*",
                "--redirect-url=https://${local.prometheus.domain}/oauth2/callback",
              ], local.prometheus.oidc.oauth2_proxy_extra_args)
              image = local.oauth2_proxy_image
              name  = "prometheus-proxy"
              ports = [
                {
                  containerPort = 9091
                  name          = "proxy"
                },
              ]
            },
          ]
          alertingEndpoints = [
            {
              name      = "kube-prometheus-stack-alertmanager"
              namespace = "kube-prometheus-stack"
              port      = 9093
            },
          ]
          externalLabels = {
            prometheus = "prometheus-${var.cluster_name}"
          }
          }, var.metrics_storage_main != null ? {
          thanos = {
            objectStorageConfig = {
              existingSecret = {
                name = "thanos-objectstorage"
                key  = "thanos.yaml"
              }
            }
          }
        } : null)
        service = {
          additionalPorts = [
            {
              name       = "proxy"
              port       = 9091
              targetPort = 9091
            },
          ]
        }
        } : null, {
        enabled = local.prometheus.enabled
        thanosService = {
          enabled = var.metrics_storage_main != null ? true : false
        }
        }
      )
    }
  }]
}

resource "random_password" "grafana_admin_password" {
  length  = 16
  special = false
}
