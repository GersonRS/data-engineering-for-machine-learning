output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "cluster_dns" {
  description = "pinot cluster dns"
  value       = "pinot.${var.namespace}.svc.cluster.local:9000"
}
output "cluster_ip" {
  description = "pinot cluster ip internal"
  value = data.kubernetes_service.pinot.spec[0].cluster_ip
}

output "endpoint" {
  description = "pinot endpoint external"
  value = "https://pinot.apps.${var.cluster_name}.${var.base_domain}"
}
