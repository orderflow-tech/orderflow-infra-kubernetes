#!/bin/bash

# Script para preparar o backend S3 do Terraform

set -e

echo "🔧 Configurando backend S3 para Terraform..."

# Verificar se AWS CLI está configurado
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ Erro: AWS CLI não está configurado"
    echo "Configure com: aws configure"
    exit 1
fi

BUCKET_NAME="orderflow-terraform-state"
DYNAMODB_TABLE="orderflow-terraform-locks"
REGION="us-east-1"

# Criar bucket S3 se não existir
if ! aws s3 ls "s3://$BUCKET_NAME" &> /dev/null; then
    echo "📦 Criando bucket S3: $BUCKET_NAME"
    aws s3 mb "s3://$BUCKET_NAME" --region $REGION
    
    # Habilitar versionamento
    echo "🔄 Habilitando versionamento..."
    aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled
    
    # Habilitar criptografia
    echo "🔐 Habilitando criptografia..."
    aws s3api put-bucket-encryption --bucket $BUCKET_NAME --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'
    
    # Bloquear acesso público
    echo "🔒 Bloqueando acesso público..."
    aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
else
    echo "✅ Bucket S3 já existe: $BUCKET_NAME"
fi

# Criar tabela DynamoDB se não existir
if ! aws dynamodb describe-table --table-name $DYNAMODB_TABLE &> /dev/null; then
    echo "🗃️ Criando tabela DynamoDB: $DYNAMODB_TABLE"
    aws dynamodb create-table \
        --table-name $DYNAMODB_TABLE \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
        --region $REGION
    
    echo "⏳ Aguardando tabela ficar ativa..."
    aws dynamodb wait table-exists --table-name $DYNAMODB_TABLE
else
    echo "✅ Tabela DynamoDB já existe: $DYNAMODB_TABLE"
fi

echo ""
echo "✅ Backend S3 configurado com sucesso!"
echo "📦 Bucket: $BUCKET_NAME"
echo "🗃️ Tabela DynamoDB: $DYNAMODB_TABLE"
echo ""
echo "💡 Para usar o backend S3, descomente as linhas no arquivo versions.tf"