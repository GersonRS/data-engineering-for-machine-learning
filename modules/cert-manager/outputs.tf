output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = module.self-signed.id
}
