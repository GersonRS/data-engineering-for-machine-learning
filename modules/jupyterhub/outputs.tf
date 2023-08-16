output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "cluster_ip" {
  description = "Jupyterhub cluster ip internal"
  value = data.kubernetes_service.jupyterhub.spec[0].cluster_ip
}

output "endpoint" {
  description = "Jupyterhub endpoint external"
  value = "https://jupyterhub.apps.${var.cluster_name}.${var.base_domain}"
}
