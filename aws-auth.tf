resource "kubernetes_config_map_v1" "aws_auth" {
  depends_on = [module.eks.cluster_id]

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
}