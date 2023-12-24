output "id" {
  description = "ID to pass other modules in order to refer to this module as a dependency."
  value       = resource.null_resource.this.id
}

output "extra_tokens" {
  description = "Map of extra accounts that were created and their tokens."
  value       = { for account in var.extra_accounts : account => jwt_hashed_token.tokens[account].token }
  sensitive   = true
}
