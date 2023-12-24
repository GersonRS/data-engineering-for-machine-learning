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
  description = "Namespace used by Argo CD where the Application and AppProject resources should be created."
  type        = string
}

variable "target_revision" {
  description = "Override of target revision of the application chart."
  type        = string
  default     = "v3.0.0" # x-release-please-version
}

variable "namespace" {
  description = "Namespace where the applications's Kubernetes resources should be created. Namespace will be created in case it doesn't exist."
  type        = string
  default     = "traefik"
}

variable "replicas" {
  description = "Number of Traefik pods to be deployed."
  type        = string
  default     = "2"
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
