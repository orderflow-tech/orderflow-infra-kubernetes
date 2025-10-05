# checkov:skip=CKV_TF_1: Using specific version for security and reproducibility

module "cloudwatch_kms_key" {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-kms.git?ref=87be9ccb61f073b58ed56de0456214c34d793841"

  description             = "KMS key for EKS CloudWatch Logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  aliases = ["eks/${var.project_name}-${var.environment}/cloudwatch"]

  tags = var.tags
}