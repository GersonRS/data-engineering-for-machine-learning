variable "namespace" {
  description = "Namespace to deploy metallb chart to."
  default     = "metallb-system"
}

# TODO make sure it's not KIND specific and consider converting to object adding IP range length as attribute.
variable "subnet" {
  description = "Cluster docker network subnet."
  type        = string
}

variable "helm_values" {
  description = "Override values."
  type        = any
  default     = [{}]
}
