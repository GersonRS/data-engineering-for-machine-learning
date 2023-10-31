output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "cluster_dns" {
  description = "trino cluster dns"
  value       = "trino.${var.namespace}.svc.cluster.local:9000"
}
output "cluster_ip" {
  description = "trino cluster ip internal"
  value = data.kubernetes_service.trinoql.spec[0].cluster_ip
}

output "endpoint" {
  description = "trino endpoint external"
  value = "https://trino.apps.${var.cluster_name}.${var.base_domain}"
}
