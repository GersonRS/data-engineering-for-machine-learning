locals {
  helm_values = [var.distributed_mode ? {
    loki-distributed = {
      loki = {
        schemaConfig  = local.schema_config
        storageConfig = local.storage_config
        structuredConfig = {
          compactor = local.compactor
        }
      }
    }
    } : null, var.distributed_mode ? null : {
    loki_stack = {
      loki = {
        config = {
          ingester = {
            lifecycler = {
              ring = {
                kvstore = {
                  store = "memberlist"
                }
                replication_factor = 1
              }
              final_sleep = "0s"
            }
            chunk_idle_period   = "5m"
            chunk_retain_period = "30s"
          }
          schema_config  = local.schema_config
          storage_config = local.storage_config
          compactor      = local.compactor
        }
      }
    }
  }]

  schema_config = {
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

  storage_config = {
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

  compactor = {
    working_directory = "/data/compactor"
    shared_store      = "aws"
  }
}
