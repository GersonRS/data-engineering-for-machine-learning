resource "random_password" "mlflow_secretkey" {
  length  = 32
  special = false
}
resource "random_password" "airflow_secretkey" {
  length  = 32
  special = false
}

locals {
  minio_config = {
    policies = [
      {
        name = "mlflow-policy"
        statements = [
          {
            resources = ["arn:aws:s3:::mlflow-bucket"]
            actions   = ["s3:CreateBucket", "s3:DeleteBucket", "s3:GetBucketLocation", "s3:ListBucket", "s3:ListBucketMultipartUploads"]
          },
          {
            resources = ["arn:aws:s3:::mlflow-bucket/*"]
            actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
          }
        ]
      },
      {
        name = "airflow-policy"
        statements = [
          {
            resources = ["arn:aws:s3:::airflow-bucket"]
            actions   = ["s3:CreateBucket", "s3:DeleteBucket", "s3:GetBucketLocation", "s3:ListBucket", "s3:ListBucketMultipartUploads"]
          },
          {
            resources = ["arn:aws:s3:::airflow-bucket/*"]
            actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
          }
        ]
      }
    ],
    users = [
      {
        accessKey = "mlflow-user"
        secretKey = random_password.mlflow_secretkey.result
        policy    = "mlflow-policy"
      },
      {
        accessKey = "airflow-user"
        secretKey = random_password.airflow_secretkey.result
        policy    = "airflow-policy"
      }
    ],
    buckets = [
      {
        name = "mlflow"
      },
      {
        name = "airflow"
      }
    ]
  }
}
