output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "argocd_namespace" {
  description = "The namespace where to deploy Argo CD."
  value       = helm_release.argocd.metadata.0.namespace
}

output "argocd_project_names" {
  description = "The names of all the Argo CD AppProjects created by the bootstrap module."
  value       = [for i in argocd_project.modern_gitops_stack_applications : i.metadata.0.name]
}

output "argocd_server_secretkey" {
  description = "The Argo CD server secret key."
  value       = random_password.argocd_server_secretkey.result
  sensitive   = true
}

output "argocd_auth_token" {
  description = "The token to set in `ARGOCD_AUTH_TOKEN` environment variable. May be used for configuring Argo CD Terraform provider."
  value       = jwt_hashed_token.argocd.token
  sensitive   = true
}

output "argocd_accounts_pipeline_tokens" {
  description = "The Argo CD accounts pipeline tokens."
  value       = local.argocd_accounts_pipeline_tokens
  sensitive   = true
}
