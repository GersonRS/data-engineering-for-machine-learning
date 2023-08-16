#######################
## Standard variables
#######################

variable "cluster_name" {
  description = "Name given to the cluster. Value used for naming some the resources created by the module."
  type        = string
}

variable "base_domain" {
  description = "Base domain of the cluster. Value used for the ingress' URL of the application."
  type        = string
}

variable "argocd_namespace" {
  description = "Namespace used by Argo CD where the Application and AppProject resources should be created."
  type        = string
  default     = "argocd"
}

variable "target_revision" {
  description = "Override of target revision of the application chart."
  type        = string
  default     = "main" # x-release-please-version
}

variable "cluster_issuer" {
  description = "SSL certificate issuer to use. Usually you would configure this value as `letsencrypt-staging` or `letsencrypt-prod` on your root `*.tf` files."
  type        = string
  default     = "ca-issuer"
}

variable "namespace" {
  description = "Namespace where the applications's Kubernetes resources should be created. Namespace will be created in case it doesn't exist."
  type        = string
  default     = "deepstorage"
}

variable "enable_service_monitor" {
  description = "Enable Prometheus ServiceMonitor in the Helm chart."
  type        = bool
  default     = true
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
  description = "IDs of the other modules on which this module depends on."
  type        = map(string)
  default     = {}
}

#######################
## Module variables
#######################

# This variable is used to create policies, users and buckets instead of using hard coded values.
variable "config_minio" {
  description = "Variable to create buckets and required users and policies."

  type = object({
    policies = optional(list(object({
      name = string
      statements = list(object({
        resources = list(string)
        actions   = list(string)
      }))
    })), [])
    users = optional(list(object({
      accessKey = string
      secretKey = string
      policy    = string
    })), [])
    buckets = optional(list(object({
      name          = string
      policy        = optional(string, "none")
      purge         = optional(bool, false)
      versioning    = optional(bool, false)
      objectlocking = optional(bool, false)
    })), [])
  })

  default = {}
}

variable "oidc" {
  description = "OIDC configuration to access the MinIO web interface."

  type = object({
    issuer_url              = string
    oauth_url               = string
    token_url               = string
    api_url                 = string
    client_id               = string
    client_secret           = string
    oauth2_proxy_extra_args = optional(list(string), [])
  })

  default = null
}
