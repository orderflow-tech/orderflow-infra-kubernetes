#!/bin/bash

# Script para limpar estado do Terraform para AWS Lab
# Este script remove recursos que não podem ser criados no AWS Lab

echo "🧹 Limpando estado do Terraform para AWS Lab..."

# Remove recursos de VPC Flow Logs do estado (se existirem)
echo "Removendo recursos de VPC Flow Logs..."
terraform state rm aws_iam_role.vpc_flow_log_role 2>/dev/null || echo "  ✓ aws_iam_role.vpc_flow_log_role não encontrado no estado"
terraform state rm aws_iam_role_policy.vpc_flow_log_policy 2>/dev/null || echo "  ✓ aws_iam_role_policy.vpc_flow_log_policy não encontrado no estado"
terraform state rm aws_flow_log.vpc_flow_log 2>/dev/null || echo "  ✓ aws_flow_log.vpc_flow_log não encontrado no estado"
terraform state rm aws_cloudwatch_log_group.vpc_flow_log 2>/dev/null || echo "  ✓ aws_cloudwatch_log_group.vpc_flow_log não encontrado no estado"

# Remove outros recursos IAM que podem causar problemas
echo "Removendo outros recursos IAM problemáticos..."
terraform state rm aws_iam_role.cluster 2>/dev/null || echo "  ✓ aws_iam_role.cluster não encontrado no estado"
terraform state rm aws_iam_role.node_group 2>/dev/null || echo "  ✓ aws_iam_role.node_group não encontrado no estado"
terraform state rm aws_iam_role.aws_load_balancer_controller 2>/dev/null || echo "  ✓ aws_iam_role.aws_load_balancer_controller não encontrado no estado"
terraform state rm aws_iam_role.cluster_autoscaler 2>/dev/null || echo "  ✓ aws_iam_role.cluster_autoscaler não encontrado no estado"

# Lista recursos restantes no estado
echo ""
echo "📋 Recursos restantes no estado:"
terraform state list

echo ""
echo "✅ Limpeza concluída! Agora você pode executar:"
echo "   terraform plan"
echo "   terraform apply"
