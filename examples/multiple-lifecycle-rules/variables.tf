variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "aws_profile" {}

variable "lifecycle_rules" {
  default = [
    {
      lifecycle_prefix   = "dev"
      noncurrent_version_expiration_days = 90
      noncurrent_version_transition_days = 30
      standard_transition_days = 30
      glacier_transition_days = 60
      expiration_days = 90
    },
    {
      lifecycle_prefix   = "test"
      noncurrent_version_expiration_days = 90
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
    },
  ]
}
