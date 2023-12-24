locals {
  helm_values = [{
    loki-distributed = {
      loki = {
        schemaConfig = {
          configs = [{
            from         = "2020-10-24"
            store        = "boltdb-shipper"
            object_store = "aws"
            schema       = "v11"
            index = {
              prefix = "index_"
              period = "24h"
            }
          }]

        }
        storageConfig = {
          aws = {
            bucketnames       = "${var.logs_storage.bucket_name}"
            endpoint          = "${var.logs_storage.endpoint}"
            access_key_id     = "${var.logs_storage.access_key}"
            secret_access_key = "${var.logs_storage.secret_key}"
            s3forcepathstyle  = true
            insecure          = var.logs_storage.insecure
          }
          boltdb_shipper = {
            shared_store = "aws"
          }
        }
        structuredConfig = {
          compactor = {
            working_directory = "/data/compactor"
            shared_store      = "aws"
          }
        }
      }
    }
  }]
}
