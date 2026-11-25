# Remote state: S3 backend with native lockfile locking (Terraform >= 1.10,
# no DynamoDB table needed). The bucket is created once by ../../bootstrap.
#
# `bucket` is intentionally not committed (account-specific). Initialize with:
#   terraform init -backend-config="bucket=<TF_STATE_BUCKET>"
# CI passes it from the repository variable TF_STATE_BUCKET.
terraform {
  backend "s3" {
    key          = "envs/dev/terraform.tfstate"
    region       = "ap-northeast-2"
    encrypt      = true
    use_lockfile = true
  }
}
