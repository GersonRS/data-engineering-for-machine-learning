variable "cluster_name" {
  description = "The name to give to the cluster."
  type        = string
  default     = "kind"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the KinD cluster (images available https://hub.docker.com/r/kindest/node/tags[here])."
  type        = string
  default     = "v1.27.3"
}

variable "nodes" {
  description = "List of worker nodes to create in the KinD cluster. To increase the number of nodes, simply duplicate the objects on the list."
  type        = list(map(string))
  default = [
    {
      "platform" = "modern-devops-stack"
    },
    {
      "platform" = "modern-devops-stack"
    },
    {
      "platform" = "modern-devops-stack"
    },
  ]

  validation {
    condition     = length(var.nodes) >= 3
    error_message = "A minimum of 3 nodes is required because of the way the other DevOps Stack modules are configured."
  }
}
