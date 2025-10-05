# AWS Load Balancer Controller - Disabled for AWS Academy
# AWS Academy doesn't support OIDC providers required for service account annotations
# resource "helm_release" "aws_load_balancer_controller" {
#   count = var.enable_aws_load_balancer_controller ? 1 : 0
# 
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"
#   version    = "1.6.2"
# 
#   set {
#     name  = "clusterName"
#     value = module.eks.cluster_name
#   }
# 
#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }
# 
#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }
# 
#   depends_on = [
#     module.eks.eks_managed_node_groups
#   ]
# }

# Cluster Autoscaler - Disabled for AWS Academy
# AWS Academy doesn't support OIDC providers required for service account annotations
# resource "helm_release" "cluster_autoscaler" {
#   count = var.enable_cluster_autoscaler ? 1 : 0
# 
#   name       = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   chart      = "cluster-autoscaler"
#   namespace  = "kube-system"
#   version    = "9.29.0"
# 
#   set {
#     name  = "autoDiscovery.clusterName"
#     value = module.eks.cluster_name
#   }
# 
#   set {
#     name  = "awsRegion"
#     value = var.region
#   }
# 
#   depends_on = [
#     module.eks.eks_managed_node_groups
#   ]
# }

# Metrics Server
resource "helm_release" "metrics_server" {
  count = var.enable_metrics_server ? 1 : 0

  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "3.11.0"

  set {
    name  = "args"
    value = "{--kubelet-insecure-tls,--kubelet-preferred-address-types=InternalIP\\,ExternalIP\\,Hostname}"
  }

  depends_on = [
    time_sleep.wait_for_cluster,
    null_resource.update_kubeconfig
  ]

  # Add timeout for Helm operations
  timeout = 600

  # Wait for cluster to be ready
  wait = true

  # Force recreation when cluster changes
  recreate_pods = true
}

