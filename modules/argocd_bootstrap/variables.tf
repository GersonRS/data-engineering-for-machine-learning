variable "namespace" {
  description = "Namespace where to deploy Argo CD."
  type        = string
  default     = "argocd"
}

variable "argocd_projects" {
  description = <<-EOT
    List of AppProject definitions to be created in Argo CD. By default, no projects are created since this variable defaults to an empty map.
    
    At a minimum, you need to provide the `destination_cluster` value, so that the destination cluster can be defined in the project. The name of the project is derived from the key of the map.

    *The first cluster in the list should always be your main cluster where the Argo CD will be deployed, and the destination cluster for that project must be `in-cluster`.* 
  EOT
  type = map(object({
    destination_cluster  = string
    allowed_source_repos = optional(list(string), ["*"])
    allowed_namespaces   = optional(list(string), ["*"])
  }))
  default = {}

  validation {
    condition     = length(keys(var.argocd_projects)) > 0 ? values(var.argocd_projects)[0].destination_cluster == "in-cluster" : true
    error_message = "The first AppProject definition provided must be for the cluster 'in-cluster'."
  }
}

variable "helm_values" {
  description = "Helm chart value overrides. They should be passed as a list of HCL structures."
  type        = any
  default = [{
    argo-cd = {}
  }]
}
