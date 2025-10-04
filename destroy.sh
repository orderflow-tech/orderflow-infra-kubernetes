#!/bin/bash

set -e

echo "Iniciando destruição da infraestrutura AWS EKS..."

if [ ! -d ".terraform" ]; then
    echo "ERRO: Terraform não está inicializado"
    exit 1
fi

echo "ATENÇÃO: Esta ação irá destruir TODA a infraestrutura!"
echo "Tem certeza que deseja continuar? (y/N)"
read -r response

if [ "$response" = "y" ] || [ "$response" = "Y" ]; then
    echo "Destruindo infraestrutura..."
    terraform destroy -auto-approve
    echo "Infraestrutura destruída!"
    rm -f tfplan terraform.tfstate.backup
else
    echo "Destruição cancelada"
fi
