# IAM Roles are pre-created in AWS Academy - use data sources instead
# AWS Academy doesn't allow creating IAM roles, so we use existing lab roles

data "aws_iam_role" "cluster" {
  name = "c173096a4485959l11929557t1w285654-LabEksClusterRole-4RwAkeZCCDlY"
}

data "aws_iam_role" "node_group" {
  name = "c173096a4485959l11929557t1w285654864-LabEksNodeRole-DqWPx0IgWLjd"
}

# Commented out - AWS Academy doesn't allow role creation
# resource "aws_iam_role" "cluster" {
#   name = "${var.project_name}-cluster-role"
# 
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "eks.amazonaws.com"
#         }
#       }
#     ]
#   })
# 
#   tags = var.tags
# }
# 
# resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.cluster.name
# }

# Commented out - AWS Academy doesn't allow role creation
# resource "aws_iam_role" "node_group" {
#   name = "${var.project_name}-node-group-role"
# 
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# 
#   tags = var.tags
# }
# 
# resource "aws_iam_role_policy_attachment" "node_group_AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.node_group.name
# }
# 
# resource "aws_iam_role_policy_attachment" "node_group_AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.node_group.name
# }
# 
# resource "aws_iam_role_policy_attachment" "node_group_AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.node_group.name
# }

# IAM Role para AWS Load Balancer Controller - Disabled for AWS Academy
# AWS Academy doesn't support OIDC providers and has limited IAM permissions
# resource "aws_iam_role" "aws_load_balancer_controller" {
#   count = var.enable_aws_load_balancer_controller ? 1 : 0
#   name  = "${var.project_name}-aws-load-balancer-controller"
#   
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Principal = {
#           Federated = module.eks.oidc_provider_arn
#         }
#         Condition = {
#           StringEquals = {
#             "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:aws-load-balancer-controller"
#             "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
#   
#   tags = var.tags
# }

# AWS Load Balancer Controller Policy - Disabled for AWS Academy
# resource "aws_iam_policy" "aws_load_balancer_controller" {
#   count = var.enable_aws_load_balancer_controller ? 1 : 0
#   name  = "${var.project_name}-AWSLoadBalancerControllerIAMPolicy"
# 
#   policy = jsonencode({
#     # ... policy content omitted for brevity in Academy environment
#   })
# }
# 
# resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
#   count      = var.enable_aws_load_balancer_controller ? 1 : 0
#   policy_arn = aws_iam_policy.aws_load_balancer_controller[0].arn
#   role       = aws_iam_role.aws_load_balancer_controller[0].name
# }

# IAM Role para Cluster Autoscaler - Disabled for AWS Academy
# AWS Academy doesn't support OIDC providers and has limited IAM permissions
# resource "aws_iam_role" "cluster_autoscaler" {
#   count = var.enable_cluster_autoscaler ? 1 : 0
#   name  = "${var.project_name}-cluster-autoscaler"
# 
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRoleWithWebIdentity"
#         Effect = "Allow"
#         Principal = {
#           Federated = module.eks.oidc_provider_arn
#         }
#         Condition = {
#           StringEquals = {
#             "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:sub" = "system:serviceaccount:kube-system:cluster-autoscaler"
#             "${replace(module.eks.cluster_oidc_issuer_url, "https://", "")}:aud" = "sts.amazonaws.com"
#           }
#         }
#       }
#     ]
#   })
# 
#   tags = var.tags
# }
# 
# resource "aws_iam_policy" "cluster_autoscaler" {
#   count = var.enable_cluster_autoscaler ? 1 : 0
#   name  = "${var.project_name}-cluster-autoscaler"
# 
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = [
#           "autoscaling:DescribeAutoScalingGroups",
#           "autoscaling:DescribeAutoScalingInstances",
#           "autoscaling:DescribeLaunchConfigurations",
#           "autoscaling:DescribeTags",
#           "autoscaling:SetDesiredCapacity",
#           "autoscaling:TerminateInstanceInAutoScalingGroup",
#           "ec2:DescribeLaunchTemplateVersions"
#         ]
#         Effect   = "Allow"
#         Resource = "*"
#       }
#     ]
#   })
# }
# 
# resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
#   count      = var.enable_cluster_autoscaler ? 1 : 0
#   policy_arn = aws_iam_policy.cluster_autoscaler[0].arn
#   role       = aws_iam_role.cluster_autoscaler[0].name
# }

