output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "argocd_project_name" {
  description = "The name of all the Argo CD AppProjects created by the strimzi module."
  value       = argocd_project.this[0].metadata.0.name
}
