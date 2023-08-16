output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "external_ip" {
  description = "External IP address of Traefik LB service."
  value       = data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip
}
