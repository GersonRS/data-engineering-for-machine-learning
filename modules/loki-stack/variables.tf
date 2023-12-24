#######################
## Standard variables
#######################

variable "argocd_namespace" {
  description = "Namespace used by Argo CD where the Application and AppProject resources should be created."
  type        = string
  default     = "argocd"
}

variable "target_revision" {
  description = "Override of target revision of the application chart."
  type        = string
  default     = "v4.0.2" # x-release-please-version
}

variable "namespace" {
  description = "Namespace where the applications's Kubernetes resources should be created. Namespace will be created in case it doesn't exist."
  type        = string
  default     = "loki-stack"
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

variable "distributed_mode" {
  description = "Boolean to activate Loki in distributed mode."
  type        = bool
  default     = false
}

variable "ingress" {
  description = "Loki frontend ingress configuration."
  type = object({
    hosts          = list(string)
    cluster_issuer = string
    allowed_ips    = optional(list(string), [])
  })
  default = null
}

variable "enable_filebeat" {
  description = "" # TODO
  type        = bool
  default     = false
}

variable "retention" {
  description = "Logs retention period.To deactivate retention, pass 0s."
  type        = string
  default     = "30d"

  validation {
    condition     = var.retention != null
    error_message = "Variable must not be null."
  }
}
