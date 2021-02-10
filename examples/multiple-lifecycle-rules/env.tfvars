aws_region = "us-east-2"

lifecycle_rules = [
    {
      lifecycle_prefix   = "dev"
      noncurrent_version_expiration_days = 365
      noncurrent_version_transition_days = 30
      standard_transition_days = 30
      glacier_transition_days = 60
      expiration_days = 365
    },
    {
      lifecycle_prefix   = "prod"
      noncurrent_version_expiration_days = 365
      noncurrent_version_transition_days = 30
      standard_transition_days = 30
      glacier_transition_days = 60
      expiration_days = 365
    }
  ]
