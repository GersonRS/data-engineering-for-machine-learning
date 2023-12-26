#######################
## Module variables
#######################

variable "oidc" {
  description = "OIDC configuration to access the MinIO web interface."

  type = object({
    issuer_url              = optional(string, "")
    oauth_url               = optional(string, "")
    token_url               = optional(string, "")
    api_url                 = optional(string, "")
    client_id_saml          = optional(string, "")
    client_secret           = optional(string, "")
    oauth2_proxy_extra_args = optional(list(string), [])
    fingerprint             = optional(string, "")
  })

  default = {}
}

variable "metrics_storage" {
  description = "MinIO S3 bucket configuration values for the bucket where the archived metrics will be stored."
  type = object({
    bucket_name       = string
    endpoint          = string
    access_key        = string
    secret_access_key = string
  })
}
