# VPC Flow Logs disabled for AWS Lab environment due to IAM restrictions
# resource "aws_flow_log" "vpc_flow_log" {
#   iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
#   log_destination = aws_cloudwatch_log_group.vpc_flow_log.arn
# }
#
# resource "aws_iam_role" "vpc_flow_log_role" {
#   name = "${var.project_name}-vpc-flow-log-role"
#
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "vpc-flow-logs.amazonaws.com"
#         }
#       }
#     ]
#   })
#
#   tags = var.tags
# }
#
# resource "aws_iam_role_policy" "vpc_flow_log_policy" {
#   name = "${var.project_name}-vpc-flow-log-policy"
#   role = aws_iam_role.vpc_flow_log_role.id
#
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "logs:CreateLogStream",
#           "logs:PutLogEvents"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "${aws_cloudwatch_log_group.vpc_flow_log.arn}:*"
#         ]
#       },
#       {
#         Action = [
#           "logs:DescribeLogGroups",
#           "logs:DescribeLogStreams"
#         ]
#         Effect = "Allow"
#         Resource = [
#           "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
#         ]
#       }
#     ]
#   })