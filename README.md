# Terraform - AWS EKS Infrastructure

Este diretório contém a configuração Terraform para provisionar um cluster Amazon EKS completo com toda a infraestrutura necessária.

## Arquitetura

A infraestrutura provisionada inclui:

### Rede
- **VPC** com CIDR configurável
- **3 Subnets Públicas** (uma por AZ)
- **3 Subnets Privadas** (uma por AZ)
- **Internet Gateway** para acesso à internet
- **3 NAT Gateways** (um por subnet pública)
- **Route Tables** configuradas adequadamente

### Segurança
- **Security Groups** para cluster, nodes e RDS
- **IAM Roles** e políticas para EKS, nodes e add-ons
- **Network Policies** para isolamento de rede
- **RBAC** configurado no Kubernetes

### EKS Cluster
- **Cluster EKS** com versão configurável do Kubernetes
- **Managed Node Groups** com auto scaling
- **Add-ons essenciais**: CoreDNS, kube-proxy, VPC CNI, EBS CSI Driver

### Add-ons via Helm
- **AWS Load Balancer Controller** para ALB/NLB
- **Cluster Autoscaler** para scaling automático
- **Metrics Server** para métricas de recursos

## Pré-requisitos

### Ferramentas Necessárias
```bash
# AWS CLI
aws --version

# Terraform
terraform --version

# kubectl
kubectl version --client

# Helm (opcional)
helm version
```

### Configuração AWS
```bash
# Configurar credenciais AWS
aws configure

# Verificar acesso
aws sts get-caller-identity
```

## Estrutura dos Arquivos

```
terraform/
├── versions.tf              # Versões dos providers
├── variables.tf             # Definição de variáveis
├── providers.tf             # Configuração dos providers
├── vpc.tf                   # Configuração da VPC
├── security-groups.tf       # Security Groups
├── iam.tf                   # IAM Roles e Políticas
├── eks.tf                   # Cluster EKS
├── helm.tf                  # Add-ons via Helm
├── outputs.tf               # Outputs
├── terraform.tfvars.example # Exemplo de variáveis
├── deploy.sh                # Script de deploy
├── destroy.sh               # Script de destruição
└── README.md                # Esta documentação
```

## Como Usar

### 1. Configuração Inicial

```bash
# Copiar e editar variáveis
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars
```

### 2. Deploy Automatizado

```bash
# Executar script de deploy
./deploy.sh
```

### 3. Deploy Manual

```bash
# Inicializar Terraform
terraform init

# Planejar mudanças
terraform plan

# Aplicar mudanças
terraform apply

# Configurar kubectl
aws eks update-kubeconfig --region us-east-1 --name orderflow-prod
```

### 4. Verificação

```bash
# Verificar nodes
kubectl get nodes

# Verificar add-ons
kubectl get pods -n kube-system

# Verificar storage classes
kubectl get storageclass
```

### 5. Destruição

```bash
# Executar script de destruição
./destroy.sh

# Ou manualmente
terraform destroy
```

## Configurações Importantes

### Variáveis Principais

| Variável | Descrição | Padrão |
|----------|-----------|---------|
| `project_name` | Nome do projeto | `orderflow` |
| `environment` | Ambiente | `prod` |
| `region` | Região AWS | `us-east-1` |
| `cluster_version` | Versão do Kubernetes | `1.28` |
| `node_group_instance_types` | Tipos de instância | `["t3.medium", "t3.large"]` |
| `node_group_desired_capacity` | Capacidade desejada | `3` |
| `node_group_max_capacity` | Capacidade máxima | `10` |
| `node_group_min_capacity` | Capacidade mínima | `1` |

### Custos Estimados

**Recursos Principais:**
- EKS Cluster: ~$73/mês
- 3x t3.medium nodes: ~$95/mês
- 3x NAT Gateways: ~$135/mês
- EBS volumes: ~$30/mês
- **Total estimado: ~$333/mês**

### Segurança

**Implementações de Segurança:**
- Nodes em subnets privadas
- Security Groups restritivos
- IAM roles com princípio do menor privilégio
- Encryption at rest habilitado
- Network policies configuradas
- RBAC implementado

### Alta Disponibilidade

**Características de HA:**
- Multi-AZ deployment
- Auto Scaling Groups
- Load Balancers
- Health checks
- Rolling updates

## Troubleshooting

### Problemas Comuns

**1. Erro de permissões AWS**
```bash
# Verificar credenciais
aws sts get-caller-identity

# Verificar permissões necessárias
aws iam get-user
```

**2. Cluster não acessível**
```bash
# Reconfigurar kubectl
aws eks update-kubeconfig --region us-east-1 --name orderflow-prod

# Verificar conectividade
kubectl get svc
```

**3. Nodes não aparecem**
```bash
# Verificar node groups
aws eks describe-nodegroup --cluster-name orderflow-prod --nodegroup-name main

# Verificar logs
kubectl describe nodes
```

**4. Add-ons com problemas**
```bash
# Verificar status dos add-ons
kubectl get pods -n kube-system

# Verificar logs específicos
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

### Logs e Monitoramento

```bash
# Logs do cluster
aws logs describe-log-groups --log-group-name-prefix /aws/eks

# Métricas dos nodes
kubectl top nodes

# Status dos pods
kubectl get pods --all-namespaces
```

## Customização

### Adicionando Novos Add-ons

```hcl
# Exemplo: Prometheus
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"
  
  create_namespace = true
}
```

### Modificando Node Groups

```hcl
# Adicionar novo node group
spot_nodes = {
  name           = "spot-nodes"
  instance_types = ["t3.large", "t3.xlarge"]
  capacity_type  = "SPOT"
  
  min_size     = 0
  max_size     = 10
  desired_size = 2
}
```

### Configurações de Rede Avançadas

```hcl
# Adicionar VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
}
```

## Backup e Disaster Recovery

### Estado do Terraform
- Estado armazenado no S3 com versionamento
- Lock distribuído via DynamoDB
- Backup automático habilitado

### Cluster EKS
- Snapshots automáticos dos volumes EBS
- Backup de configurações via GitOps
- Procedimentos de restore documentados

## Próximos Passos

Após provisionar a infraestrutura:

1. **Deploy da aplicação**: `cd ../k8s && ./deploy.sh`
2. **Configurar monitoramento**: Instalar Prometheus/Grafana
3. **Configurar CI/CD**: Integrar com GitHub Actions
4. **Configurar backup**: Implementar Velero
5. **Configurar logging**: Instalar ELK Stack

