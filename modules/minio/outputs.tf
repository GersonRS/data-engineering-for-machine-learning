output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "minio_root_user_credentials" {
  description = "The MinIO root user password."
  value = {
    username = "root"
    password = random_password.minio_root_secretkey.result
  }
  sensitive = true
}

output "cluster_dns" {
  description = "MinIO cluster dns endpoint where the buckets are available."
  value       = "minio.${var.namespace}.svc.cluster.local:9000"
}
output "cluster_ip" {
  description = "MinIO cluster ip internal"
  value       = data.kubernetes_service.minio.spec[0].cluster_ip
}

output "endpoint" {
  description = "MinIO endpoint external"
  value       = "https://minio.apps.${var.cluster_name}.${var.base_domain}"
}
