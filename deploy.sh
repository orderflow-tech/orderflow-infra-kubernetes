#!/bin/bash

# Script para inicializar e aplicar a infraestrutura Terraform

set -e

echo "Iniciando provisionamento da infraestrutura AWS EKS..."

# Verificar se AWS CLI está configurado
if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERRO: AWS CLI não está configurado"
    echo "Configure com: aws configure"
    exit 1
fi

# Verificar se Terraform está instalado
if ! command -v terraform &> /dev/null; then
    echo "ERRO: Terraform não está instalado"
    exit 1
fi

# Verificar se kubectl está instalado
if ! command -v kubectl &> /dev/null; then
    echo "ERRO: kubectl não está instalado"
    exit 1
fi

# Criar arquivo terraform.tfvars se não existir
if [ ! -f terraform.tfvars ]; then
    echo "Criando terraform.tfvars a partir do exemplo..."
    cp terraform.tfvars.example terraform.tfvars
    echo "AVISO: Edite o arquivo terraform.tfvars com suas configurações específicas"
    read -p "Pressione Enter para continuar após editar o arquivo..."
fi

# Inicializar Terraform
echo "Inicializando Terraform..."
terraform init

# Validar configuração
echo "Validando configuração..."
terraform validate

# Planejar mudanças
echo "Planejando mudanças..."
terraform plan -out=tfplan

# Confirmar aplicação
echo "Deseja aplicar as mudanças? (y/N)"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Aplicando mudanças..."
    terraform apply tfplan
    
    # Configurar kubectl
    echo "Configurando kubectl..."
    CLUSTER_NAME=$(terraform output -raw cluster_name)
    REGION=$(terraform output -raw region || echo "us-east-1")
    
    aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
    
    echo "Infraestrutura provisionada com sucesso!"
    echo ""
    echo "Informações do cluster:"
    echo "Nome: $CLUSTER_NAME"
    echo "Região: $REGION"
    echo "Endpoint: $(terraform output -raw cluster_endpoint)"
    echo ""
    echo "Para verificar o status do cluster:"
    echo "kubectl get nodes"
    echo "kubectl get pods --all-namespaces"
    echo ""
    echo "Para fazer deploy da aplicacao:"
    echo "cd ../k8s && ./deploy.sh"
    
else
    echo "Aplicacao cancelada"
    rm -f tfplan
fi