module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.0.0"

  cluster_name    = "${var.project_name}-${var.environment}"
  cluster_version = var.cluster_version

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id
  # checkov:skip=CKV_AWS_37:Public endpoint access is required for AWS Academy setup
  cluster_endpoint_public_access = true

  # AWS Academy compatible configuration
  enable_irsa = false # Disable IRSA for AWS Academy

  # Use custom IAM roles to avoid session context issues
  create_iam_role = false
  iam_role_arn    = data.aws_iam_role.cluster.arn

  # Manage aws-auth ConfigMap
  manage_aws_auth_configmap = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  eks_managed_node_groups = {
    main = {
      name = "${var.project_name}-node-group"

      instance_types = var.node_group_instance_types
      capacity_type  = "ON_DEMAND"

      min_size     = var.node_group_min_capacity
      max_size     = var.node_group_max_capacity
      desired_size = var.node_group_desired_capacity

      ami_type = "AL2_x86_64"

      disk_size = 50

      # Use existing AWS Academy IAM role - disable role creation
      create_iam_role = false
      iam_role_arn    = data.aws_iam_role.node_group.arn

      # Disable launch template to avoid user data issues
      use_custom_launch_template = false

      # Basic configuration without SSH access for simplicity
      # SSH access can be configured later if needed

      # Node group update configuration
      update_config = {
        max_unavailable_percentage = 25
      }

      # Kubernetes labels
      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      # Kubernetes taints
      taints = {}

      tags = merge(var.tags, {
        "k8s.io/cluster-autoscaler/enabled"                                = "true"
        "k8s.io/cluster-autoscaler/${var.project_name}-${var.environment}" = "owned"
      })
    }
  }

  # Cluster security group
  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  # Node security group
  # checkov:skip=CKV_AWS_260:Node group requires internet access for container image pulls and AWS service communication
  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = var.tags
}

# Key pair para acesso SSH aos nodes
resource "tls_private_key" "eks_nodes" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "eks_nodes" {
  key_name   = "${var.project_name}-eks-nodes"
  public_key = tls_private_key.eks_nodes.public_key_openssh

  tags = var.tags
}

