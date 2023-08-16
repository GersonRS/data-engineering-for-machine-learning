output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "teste1" {
  value = yamldecode(file("${path.module}/test.yaml"))
}
output "teste2" {
  value = yamlencode(local.helm_values)
}
