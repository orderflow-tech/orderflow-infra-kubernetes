# checkov:skip=CKV_TF_1: Using specific version commit hash for security and reproducibility
module "cloudwatch_kms_key" {
  source = "github.com/terraform-aws-modules/terraform-aws-kms?ref=5b76b18f5999495ae1c1ac5524de519025fcde10"

  description             = "KMS key for EKS CloudWatch Logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  aliases = ["eks/${var.project_name}-${var.environment}/cloudwatch"]

  tags = var.tags
}