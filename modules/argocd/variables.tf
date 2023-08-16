variable "namespace" {
  description = "Namespace where to deploy Argo CD."
  type        = string
  default     = "cicd"
}

variable "helm_values" {
  description = "Helm chart value overrides. They should be passed as a list of HCL structures."
  type        = any
  default = [{
    argo-cd = {}
  }]
}
