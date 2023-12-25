locals {
  metrics_storage = var.metrics_storage != null ? {
    storage_config = {
      type = "s3"
      config = {
        bucket     = var.metrics_storage.bucket_name
        endpoint   = var.metrics_storage.endpoint
        access_key = var.metrics_storage.access_key
        secret_key = var.metrics_storage.secret_key
        insecure   = var.metrics_storage.insecure
      }
    }
  } : null

  helm_values = []
}
