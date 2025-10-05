module "cloudwatch_kms_key" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.1.0"

  description             = "KMS key for EKS CloudWatch Logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  aliases = ["eks/${var.project_name}-${var.environment}/cloudwatch"]

  tags = var.tags
}