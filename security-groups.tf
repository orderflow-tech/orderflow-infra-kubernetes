# Security Group para EKS Cluster
#checkov:skip=CKV2_AWS_5:This security group is automatically attached to the EKS cluster control plane network interfaces by AWS during cluster creation. The terraform-aws-eks module (module.eks) references this security group in the aws_eks_cluster resource and AWS automatically creates ENIs with this security group. AWS handles the attachment as part of the EKS service.
resource "aws_security_group" "cluster" {
  name_prefix = "${var.project_name}-cluster-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for EKS cluster control plane"

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "HTTPS egress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS egress (UDP)"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS egress (TCP)"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-cluster-sg"
  })
}

# Security Group para Worker Nodes
#checkov:skip=CKV2_AWS_5:This security group is actively used by EKS managed node group. The attachment is handled by the EKS module (module.eks) which creates the node group and automatically attaches this security group to the EC2 instances' ENIs. Reference: eks_managed_node_groups in terraform-aws-eks module.
resource "aws_security_group" "node_group" {
  name_prefix = "${var.project_name}-node-group-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for EKS worker nodes"

  ingress {
    description = "Node to node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description     = "Cluster API to node groups"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  ingress {
    description     = "Cluster API to node kubelets"
    from_port       = 10250
    to_port         = 10250
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  ingress {
    description     = "Cluster API to node group"
    from_port       = 1025
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.cluster.id]
  }

  egress {
    description = "HTTPS egress"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS egress (UDP)"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS egress (TCP)"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Node to node communication"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    self        = true
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-node-group-sg"
  })
}

# Security Group para RDS
#checkov:skip=CKV2_AWS_5:This security group is pre-created for future RDS instances and will be attached when those instances are created in subsequent deployments. This is a common practice in infrastructure-as-code to separate security group definitions from resource creation.
resource "aws_security_group" "rds" {
  name_prefix = "${var.project_name}-rds-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for RDS instances"

  ingress {
    description     = "PostgreSQL from EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.node_group.id]
  }

  egress {
    description     = "PostgreSQL to EKS nodes"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.node_group.id]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-rds-sg"
  })
}

