#######################
## Standard variables
#######################

variable "cluster_name" {
  description = "Name given to the cluster. Value used for the ingress' URL of the application."
  type        = string
}

variable "base_domain" {
  description = "Base domain of the cluster. Value used for the ingress' URL of the application."
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace used by Argo CD where the Application and AppProject resources should be created. Normally, it should take the outputof the namespace from the bootstrap module."
  type        = string
  default     = "argocd"
}

variable "argocd_project" {
  description = "Name of the Argo CD AppProject where the Application should be created. If not set, the Application will be created in a new AppProject only for this Application."
  type        = string
  default     = null
}

variable "argocd_labels" {
  description = "Labels to attach to the Argo CD Application resource."
  type        = map(string)
  default     = {}
}

variable "target_revision" {
  description = "Override of target revision of the application chart."
  type        = string
  default     = "develop" # x-release-please-version
}

variable "cluster_issuer" {
  description = "SSL certificate issuer to use. Usually you would configure this value as `letsencrypt-staging` or `letsencrypt-prod` on your root `*.tf` files. You can use `ca-issuer` when using the self-signed variant of cert-manager."
  type        = string
  default     = "selfsigned-issuer"
}

variable "namespace" {
  description = "Namespace where to deploy Argo CD."
  type        = string
  default     = "argocd"
}

variable "helm_values" {
  description = "Helm chart value overrides. They should be passed as a list of HCL structures."
  type        = any
  default     = []
}

variable "app_autosync" {
  description = "Automated sync options for the Argo CD Application resource."
  type = object({
    allow_empty = optional(bool)
    prune       = optional(bool)
    self_heal   = optional(bool)
  })
  default = {
    allow_empty = false
    prune       = true
    self_heal   = true
  }
}

variable "dependency_ids" {
  type    = map(string)
  default = {}
}

#######################
## Module variables
#######################

variable "resources" {
  description = <<-EOT
    Resource limits and requests for the Argo CD components. Follow the style on https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/[official documentation] to understand the format of the values.

    NOTE: The `repo_server` requests and limits will be applied to all the extra containers that are deployed with the `argocd-repo-server` component (each container has the same requests and limits as the main container, **so it is cumulative**).

    NOTE: If you enable the HA mode using the `high_availability` variable, the values for Redis will be applied to the Redis HA chart instead of the default one.
  EOT
  type = object({

    application_set = optional(object({
      requests = optional(object({
        cpu    = optional(string, "100m")
        memory = optional(string, "128Mi")
      }), {})
      limits = optional(object({
        cpu    = optional(string, "100m")
        memory = optional(string, "128Mi")
      }), {})
    }), {})

    controller = optional(object({
      requests = optional(object({
        cpu    = optional(string, "500m")
        memory = optional(string, "512Mi")
      }), {})
      limits = optional(object({
        cpu    = optional(string, "1")
        memory = optional(string, "2Gi")
      }), {})
    }), {})

    notifications = optional(object({
      requests = optional(object({
        cpu    = optional(string, "100m")
        memory = optional(string, "128Mi")
      }), {})
      limits = optional(object({
        cpu    = optional(string, "200m")
        memory = optional(string, "256Mi")
      }), {})
    }), {})

    repo_server = optional(object({
      requests = optional(object({
        cpu    = optional(string, "200m")
        memory = optional(string, "128Mi")
      }), {})
      limits = optional(object({
        cpu    = optional(string, "400m")
        memory = optional(string, "256Mi")
      }), {})
    }), {})

    server = optional(object({
      requests = optional(object({
        cpu    = optional(string, "50m")
        memory = optional(string, "128Mi")
      }), {})
      limits = optional(object({
        cpu    = optional(string, "100m")
        memory = optional(string, "256Mi")
      }), {})
    }), {})

    redis = optional(object({
      requests = optional(object({
        cpu    = optional(string, "200m")
        memory = optional(string, "64Mi")
      }), {})
      limits = optional(object({
        cpu    = optional(string, "300m")
        memory = optional(string, "128Mi")
      }), {})
    }), {})

  })
  default = {}
}

variable "high_availability" {
  description = <<-EOT
    Argo CD High Availability settings. By default, the HA is disabled.

    To enable HA using the default replicas, simply set the value `high_availability.enabled` to `true`. **This will deploy Argo CD in HA without autoscaling.**

    You can enable autoscaling of the `argocd-server` and `argocd-repo-server` components by setting the `high_availability.server.autoscaling.enabled` and `high_availability.repo_server.autoscaling.enabled` values to `true`. You can also configure the minimum and maximum replicas desired or leave the default values.

    IMPORTANT: Activating the HA mode automatically enables the Redis HA chart which requires at least 3 worker nodes, as this chart enforces Pods to run on separate nodes.

    NOTE: Since this variable uses the `optional` argument to forcing the user to define all the values, there is a side effect you can pass any other bogus value and Terraform will accept it, **but they won't be used in the chart behind the module**.
  EOT

  type = object({
    enabled = bool

    controller = optional(object({
      replicas = optional(number, 1)
    }), {})

    application_set = optional(object({
      replicas = optional(number, 2)
    }), {})

    server = optional(object({
      replicas = optional(number, 2)
      autoscaling = optional(object({
        enabled      = bool
        min_replicas = optional(number, 2)
        max_replicas = optional(number, 5)
        }), {
        enabled = false
      })
    }), {})

    repo_server = optional(object({
      replicas = optional(number, 2)
      autoscaling = optional(object({
        enabled      = bool
        min_replicas = optional(number, 2)
        max_replicas = optional(number, 5)
        }), {
        enabled = false
      })
    }), {})

  })

  default = {
    enabled = false
  }
}

variable "oidc" {
  description = "OIDC settings for the log in to the Argo CD web interface."
  type        = any
  default     = null
  # TODO Add proper OIDC variable here!
}

variable "rbac" {
  description = "RBAC settings for the Argo CD users."
  type = object({
    scopes         = optional(string, "[groups, cognito:groups, roles]")
    policy_default = optional(string, "")
    policy_csv = optional(string, <<-EOT
                                    g, pipeline, role:admin
                                    g, argocd-admin, role:admin
                                    g, modern-devops-stack-admins, role:admin
                                  EOT
    )
  })
  default = {}
}

variable "repositories" {
  description = "List of repositories to add to Argo CD."
  type        = map(map(string))
  default     = {}
}

variable "ssh_known_hosts" {
  description = <<-EOT
    List of SSH known hosts to add to Argo CD.
    
    Check the official `values.yaml` to get the format to pass this value. 
    
    IMPORTANT: If you set this variable, the default known hosts will be overridden by this value, so you might want to consider adding the ones you need here."
  EOT
  type        = string
  default     = null
}

variable "exec_enabled" {
  description = "Flag to enable the web-based terminal on Argo CD. Do not forget to set the appropriate RBAC configuration to your users/groups."
  type        = bool
  default     = false
}

variable "admin_enabled" {
  description = "Flag to indicate whether to enable the administrator user."
  type        = bool
  default     = false
}

variable "accounts_pipeline_tokens" {
  description = "API token for pipeline account."
  type        = string
  sensitive   = true
}

variable "server_secretkey" {
  description = "Signature key for session validation. *Must reuse the bootstrap output containing the secretkey.*"
  type        = string
  sensitive   = false
}

variable "extra_accounts" {
  description = "List of accounts for which tokens will be generated."
  type        = list(string)
  default     = []
}

variable "repo_server_iam_role_arn" {
  description = "IAM role ARN to associate with the argocd-repo-server ServiceAccount. This role can be used to give SOPS access to AWS KMS."
  type        = string
  default     = null
}

variable "repo_server_azure_workload_identity_clientid" {
  description = "Azure AD Workload Identity Client-ID to associate with argocd-repo-server. This role can be used to give SOPS access to a Key Vault."
  type        = string
  default     = null
}

variable "repo_server_aadpodidbinding" {
  description = "Azure AAD Pod Identity to associate with the argocd-repo-server Pod. This role can be used to give SOPS access to a Key Vault."
  type        = string
  default     = null
}

variable "helmfile_cmp_version" {
  description = "Version of the helmfile-cmp plugin."
  type        = string
  default     = "0.1.1"
}

variable "helmfile_cmp_env_variables" {
  description = "List of environment variables to attach to the helmfile-cmp plugin, usually used to pass authentication credentials. Use an https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/[explicit format] or take the values from a https://kubernetes.io/docs/tasks/inject-data-application/distribute-credentials-secure/#define-container-environment-variables-using-secret-data[Kubernetes secret]."
  type = list(object({
    name  = optional(string)
    value = optional(string)
    valueFrom = optional(object({
      secretKeyRef = optional(object({
        name = optional(string)
        key  = optional(string)
      }))
    }))
  }))
  default = []
}
