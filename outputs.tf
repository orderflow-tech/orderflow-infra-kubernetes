output "cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "ID do security group do cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "Nome do IAM role do cluster"
  value       = data.aws_iam_role.cluster.name
}

output "cluster_iam_role_arn" {
  description = "ARN do IAM role do cluster"
  value       = data.aws_iam_role.cluster.arn
}

output "cluster_certificate_authority_data" {
  description = "Dados do certificado de autoridade do cluster"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.eks.cluster_name
}

output "cluster_oidc_issuer_url" {
  description = "URL do OIDC issuer do cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

output "node_groups" {
  description = "Informações dos node groups"
  value       = module.eks.eks_managed_node_groups
}

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "private_subnets" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

output "public_subnets" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "security_group_ids" {
  description = "IDs dos security groups"
  value = {
    cluster    = aws_security_group.cluster.id
    node_group = aws_security_group.node_group.id
    rds        = aws_security_group.rds.id
  }
}

# Outputs for AWS Load Balancer Controller and Cluster Autoscaler disabled for AWS Academy
# output "load_balancer_controller_role_arn" {
#   description = "ARN do IAM role do AWS Load Balancer Controller"
#   value       = null
# }
# 
# output "cluster_autoscaler_role_arn" {
#   description = "ARN do IAM role do Cluster Autoscaler"
#   value       = null
# }

output "eks_node_key_pair_name" {
  description = "Nome do key pair para acesso SSH aos nodes"
  value       = aws_key_pair.eks_nodes.key_name
}

output "eks_node_private_key" {
  description = "Chave privada para acesso SSH aos nodes"
  value       = tls_private_key.eks_nodes.private_key_pem
  sensitive   = true
}

output "region" {
  description = "Região AWS utilizada"
  value       = var.region
}

output "kubectl_config" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

