output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "cluster_dns" {
  description = "Ray cluster dns"
  value       = "ray-kuberay-head-svc.${var.namespace}.svc.cluster.local"
}
output "cluster_ip" {
  description = "Ray cluster ip internal"
  value       = data.kubernetes_service.ray.spec[0].cluster_ip
}

output "endpoint" {
  description = "Ray endpoint external"
  value       = "https://ray.apps.${var.cluster_name}.${var.base_domain}"
}
