variable "metrics_storage" {
  description = "MinIO S3 bucket configuration values for the bucket where the archived metrics will be stored."
  type = object({
    bucket_name = string
    endpoint    = string
    access_key  = string
    secret_key  = string
    insecure    = optional(bool, true)
  })
  default = null
}
