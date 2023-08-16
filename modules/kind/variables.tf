variable "cluster_name" {
  description = "The name to give to the cluster."
  type        = string
  default     = "kind"
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the KinD cluster (images available https://hub.docker.com/r/kindest/node/tags[here])."
  type        = string
  default     = "v1.26.0"
}

variable "nodes" {
  description = "List of nodes"
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
    }
  ]
}
