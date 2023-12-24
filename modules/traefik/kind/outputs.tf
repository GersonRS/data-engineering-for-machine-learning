output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency. It takes the ID that comes from the main module and passes it along to the code that called this variant in the first place."
  value       = module.traefik.id
}

output "external_ip" {
  description = "External IP address of Traefik LB service."
  value       = data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip
}
