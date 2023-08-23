output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "credentials" {
  value = local.credentials
}

output "cluster_dns" {
  description = "mysql cluster dns"
  value       = "mysql.${var.namespace}.svc.cluster.local:9000"
}
output "cluster_ip" {
  description = "mysql cluster ip internal"
  value = data.kubernetes_service.mysqlql.spec[0].cluster_ip
}

output "endpoint" {
  description = "mysql endpoint external"
  value = "https://mysql.apps.${var.cluster_name}.${var.base_domain}"
}
