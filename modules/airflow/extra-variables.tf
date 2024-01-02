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
    client_id               = optional(string, "")
    client_secret           = optional(string, "")
    oauth2_proxy_extra_args = optional(list(string), [])
    fingerprint             = optional(string, "")
  })

  default = {}
}
variable "home_ssh" {
  description = "home ssh"
  type        = string
  default     = "/home/gerson/.ssh/id_ed25519" # change here
}

variable "storage" {
  description = "MinIO S3 bucket configuration values for the bucket where the archived metrics will be stored."
  type = object({
    bucket_name       = string
    endpoint          = string
    access_key        = string
    secret_access_key = string
  })
}

variable "database" {
  description = "database configuration"
  type = object({
    user     = string
    password = string
    database = string
    endpoint = string
  })
}

variable "mlflow" {
  description = "mlflow configuration"
  type = object({
    endpoint = string
  })
  default = null
}

variable "ray" {
  description = "ray configuration"
  type = object({
    endpoint = string
  })
  default = null
}
