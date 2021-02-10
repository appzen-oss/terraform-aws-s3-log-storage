resource "aws_s3_bucket" "default" {
  #bridgecrew:skip=BC_AWS_S3_13:Skipping `Enable S3 Bucket Logging` check until bridgecrew will support dynamic blocks (https://github.com/bridgecrewio/checkov/issues/776).
  #bridgecrew:skip=CKV_AWS_52:Skipping `Ensure S3 bucket has MFA delete enabled` due to issue in terraform (https://github.com/hashicorp/terraform-provider-aws/issues/629).
  count         = module.this.enabled ? 1 : 0
  bucket        = module.this.id
  acl           = var.acl
  force_destroy = var.force_destroy
  policy        = var.policy

  versioning {
    enabled = var.versioning_enabled
  }

  dynamic "lifecycle_rule" {
    for_each = [for i in var.lifecycle_rules: {
      id = i.lifecycle_prefix 
      lifecycle_prefix = i.lifecycle_prefix
      noncurrent_version_expiration_days = i.noncurrent_version_expiration_days
      noncurrent_version_transition_days = i.noncurrent_version_transition_days
      standard_transition_days = i.standard_transition_days
      glacier_transition_days = i.glacier_transition_days
      expiration_days = i.expiration_days
      }
    ]

    content {
      id                                     = lifecycle_rule.value.id
      enabled                                = var.lifecycle_rule_enabled
      prefix                                 = lifecycle_rule.value.lifecycle_prefix
      tags                                   = var.lifecycle_tags
      abort_incomplete_multipart_upload_days = var.abort_incomplete_multipart_upload_days
    
      noncurrent_version_expiration {
        days = lifecycle_rule.value.noncurrent_version_expiration_days
      }

      dynamic "noncurrent_version_transition" {
        for_each = var.enable_glacier_transition ? [1] : []

        content {
          days          = lifecycle_rule.value.noncurrent_version_transition_days
          storage_class = "GLACIER"
        }
      }

      transition {
        days          = lifecycle_rule.value.standard_transition_days
        storage_class = "STANDARD_IA"
      }

      dynamic "transition" {
        for_each = var.enable_glacier_transition ? [1] : []

        content {
          days          = lifecycle_rule.value.glacier_transition_days
          storage_class = "GLACIER"
        }
      }

      expiration {
        days = lifecycle_rule.value.expiration_days
      }
   }
  }

  dynamic "logging" {
    for_each = var.access_log_bucket_name != "" ? [1] : []
    content {
      target_bucket = var.access_log_bucket_name
      target_prefix = "logs/${module.this.id}/"
    }
  }

  # https://docs.aws.amazon.com/AmazonS3/latest/dev/bucket-encryption.html
  # https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#enable-default-server-side-encryption
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = var.sse_algorithm
        kms_master_key_id = var.kms_master_key_arn
      }
    }
  }

  tags = module.this.tags
}

# Refer to the terraform documentation on s3_bucket_public_access_block at
# https://www.terraform.io/docs/providers/aws/r/s3_bucket_public_access_block.html
# for the nuances of the blocking options
resource "aws_s3_bucket_public_access_block" "default" {
  count  = module.this.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

## Set object_ownership to bucket_owner
resource "aws_s3_bucket_ownership_controls" "object_ownership_control" {
  count  = module.this.enabled ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)

  rule {
    object_ownership = var.object_ownership
  }
}

## Enabled s3 bucket analytics
resource "aws_s3_bucket_analytics_configuration" "entire-bucket" {
  count  = var.enabled_analytics ? 1 : 0
  bucket = join("", aws_s3_bucket.default.*.id)
  name   = "EntireBucket"

  storage_class_analysis {
    data_export {
      destination {
        s3_bucket_destination {
          bucket_arn = join("", aws_s3_bucket.analytics.*.arn) 
        }
      }
    }
  }
}

## s3 bucket analytics analytics 
resource "aws_s3_bucket" "analytics" {  
  count  = var.enabled_analytics ? 1 : 0
  bucket = var.analytics_bucket_name
}
