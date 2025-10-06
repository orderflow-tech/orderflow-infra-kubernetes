resource "kubernetes_config_map_v1" "aws_auth" {
  depends_on = [
    module.eks.cluster_id,
    module.eks.cluster_endpoint,
    module.eks.cluster_certificate_authority_data
  ]

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        rolearn  = data.aws_iam_role.cluster.arn
        username = "admin"
        groups   = ["system:masters"]
      },
      {
        rolearn  = data.aws_iam_role.node_group.arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups   = ["system:bootstrappers", "system:nodes"]
      }
    ])
  }

  lifecycle {
    ignore_changes = [data]
  }
}