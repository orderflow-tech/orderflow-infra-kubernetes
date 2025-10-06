# AWS Lab Deployment Guide

## Issues Fixed for AWS Lab Environment

### 1. Kubernetes Provider Configuration
- **Problem**: `config_path` pointing to non-existent `~/.kube/config`
- **Solution**: Updated providers to use EKS cluster endpoint directly with AWS CLI authentication

### 2. IAM Permissions Restrictions
- **Problem**: AWS Lab doesn't allow `iam:CreateRole` action
- **Solution**: Disabled VPC Flow Logs and related IAM resources (commented out in `vpc-flow-logs.tf`)

### 3. Duplicate Key Pair Error
- **Problem**: Key pair `orderflow-eks-nodes` already exists
- **Solution**: Added lifecycle rule to ignore changes to existing key pair

### 4. Kubernetes API Connection
- **Problem**: ConfigMap trying to connect to localhost
- **Solution**: Updated dependencies and added lifecycle rules

## Deployment Steps for AWS Lab

### Prerequisites
1. Ensure you're in AWS Lab environment with proper credentials
2. Have Terraform installed
3. Have AWS CLI configured

### Step 1: Clean Terraform State (CRITICAL for AWS Lab)
Se você está recebendo erros de IAM CreateRole, é porque o estado do Terraform ainda contém recursos antigos.

**Opção A - Script Automatizado (Recomendado):**
```bash
# Torne o script executável e execute
chmod +x cleanup-aws-lab.sh
./cleanup-aws-lab.sh
```

**Opção B - Manual:**
```bash
# Remove recursos de VPC Flow Logs do estado (se existirem)
terraform state rm aws_iam_role.vpc_flow_log_role 2>/dev/null || true
terraform state rm aws_iam_role_policy.vpc_flow_log_policy 2>/dev/null || true
terraform state rm aws_flow_log.vpc_flow_log 2>/dev/null || true
terraform state rm aws_cloudwatch_log_group.vpc_flow_log 2>/dev/null || true

# Refresh do estado
terraform refresh
```

### Step 2: Import Existing Key Pair (if needed)
```bash
terraform import aws_key_pair.eks_nodes orderflow-eks-nodes
```

### Step 3: Initialize Terraform
```bash
terraform init
```

### Step 4: Plan Deployment
```bash
terraform plan
```

### Step 5: Apply Configuration
```bash
terraform apply
```

## Important Notes for AWS Lab

1. **VPC Flow Logs**: Disabled due to IAM restrictions in AWS Lab
2. **IAM Roles**: Using existing AWS Lab roles instead of creating new ones
3. **Key Pairs**: Configured to work with existing key pairs
4. **Kubernetes Access**: Uses AWS CLI token authentication instead of kubeconfig files

## Troubleshooting

### Erro: "User is not authorized to perform: iam:CreateRole"
Este é o erro mais comum no AWS Lab. Soluções:

1. **Execute a limpeza do estado** (Step 1 acima)
2. **Verifique se todos os recursos IAM estão comentados** nos arquivos .tf
3. **Se o erro persistir**, pode haver recursos órfãos no estado:
   ```bash
   # Liste todos os recursos no estado
   terraform state list
   
   # Remova recursos IAM órfãos manualmente
   terraform state rm [nome_do_recurso_iam]
   ```

### Erro: "InvalidKeyPair.Duplicate"
```bash
# Opção 1: Importar key pair existente
terraform import aws_key_pair.eks_nodes orderflow-eks-nodes

# Opção 2: Remover key pair existente (se não estiver em uso)
aws ec2 delete-key-pair --key-name orderflow-eks-nodes
```

### Erro: "dial tcp [::1]:80: connect: connection refused"
Este erro indica que o provider Kubernetes está tentando se conectar antes do cluster existir:

1. **Aplique apenas recursos de infraestrutura primeiro**:
   ```bash
   terraform apply -target=module.eks
   ```

2. **Depois aplique o resto**:
   ```bash
   terraform apply
   ```

### If Kubernetes provider fails:
- Ensure the EKS cluster is fully created before applying Kubernetes resources
- Check AWS CLI is properly configured with `aws sts get-caller-identity`
- Verify cluster endpoint is accessible: `aws eks describe-cluster --name [cluster-name]`

## Post-Deployment

After successful deployment:
1. Configure kubectl: `aws eks update-kubeconfig --region <region> --name <cluster-name>`
2. Verify cluster access: `kubectl get nodes`
3. Check aws-auth configmap: `kubectl get configmap aws-auth -n kube-system -o yaml`
