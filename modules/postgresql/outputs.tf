output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "credentials" {
  value = local.credentials
}

output "cluster_dns" {
  description = "Postgres cluster dns"
  value       = "postgres.${var.namespace}.svc.cluster.local:9000"
}
output "cluster_ip" {
  description = "Postgres cluster ip internal"
  value = data.kubernetes_service.postgresql.spec[0].cluster_ip
}

output "endpoint" {
  description = "Postgres endpoint external"
  value = "https://postgres.apps.${var.cluster_name}.${var.base_domain}"
}
