output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "broker_name" {
  description = "kafka broker name"
  value       = local.helm_values[0].kafka.name
}
