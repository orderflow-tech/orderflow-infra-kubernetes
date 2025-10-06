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

### Step 1: Import Existing Key Pair (if needed)
```bash
terraform import aws_key_pair.eks_nodes orderflow-eks-nodes
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Plan Deployment
```bash
terraform plan
```

### Step 4: Apply Configuration
```bash
terraform apply
```

## Important Notes for AWS Lab

1. **VPC Flow Logs**: Disabled due to IAM restrictions in AWS Lab
2. **IAM Roles**: Using existing AWS Lab roles instead of creating new ones
3. **Key Pairs**: Configured to work with existing key pairs
4. **Kubernetes Access**: Uses AWS CLI token authentication instead of kubeconfig files

## Troubleshooting

### If you still get IAM errors:
- Check that your AWS Lab session is active
- Verify you have the necessary permissions for EKS operations

### If Kubernetes provider fails:
- Ensure the EKS cluster is fully created before applying Kubernetes resources
- Check AWS CLI is properly configured with `aws sts get-caller-identity`

### If key pair errors persist:
- Run the import command mentioned above
- Or delete the existing key pair from AWS console if not needed

## Post-Deployment

After successful deployment:
1. Configure kubectl: `aws eks update-kubeconfig --region <region> --name <cluster-name>`
2. Verify cluster access: `kubectl get nodes`
3. Check aws-auth configmap: `kubectl get configmap aws-auth -n kube-system -o yaml`
