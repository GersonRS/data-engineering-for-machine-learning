output "teste1" {
  value = yamldecode(file("${path.module}/test.yaml"))
}
# output "teste2" {
#   value = yamlencode(local.helm_values)
# }
