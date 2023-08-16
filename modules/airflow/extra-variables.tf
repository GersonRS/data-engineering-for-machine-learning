variable "credentials_storage" {
  description = "MinIO S3 bucket configuration values for the bucket where the archived metrics will be stored."
  type = object({
    bucket_name       = string
    endpoint          = string
    access_key        = string
    secret_access_key = string
  })
}

variable "credentials_database" {
  description = "database configuration"
  type = object({
    user     = string
    password = string
    database = string
    service  = string
  })
}
