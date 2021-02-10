module "s3_log_storage" {
  source  = "../.."

  enabled                  = true
  name                     = "s3-log-storage"
  stage                    = "test"
  namespace                = "eg"
  acl                      = "log-delivery-write"
  versioning_enabled       = false
  lifecycle_rule_enabled   = "true" 
  lifecycle_rules          = var.lifecycle_rules
}
