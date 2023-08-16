output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "cluster_ip" {
  description = "MLflow cluster ip internal"
  value = data.kubernetes_service.mlflow.spec[0].cluster_ip
}

output "endpoint" {
  description = "MLflow endpoint external"
  value = "https://mlflow.apps.${var.cluster_name}.${var.base_domain}"
}
