# Local variable to store kubeconfig command
locals {
  kubeconfig_update_command = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}

# Ensure kubeconfig is updated after cluster creation
resource "null_resource" "update_kubeconfig" {
  depends_on = [
    module.eks.cluster_endpoint,
    module.eks.cluster_certificate_authority_data,
    kubernetes_config_map_v1.aws_auth
  ]

  provisioner "local-exec" {
    command = local.kubeconfig_update_command
  }

  # This will force the resource to be recreated whenever the cluster endpoint changes
  triggers = {
    cluster_endpoint = module.eks.cluster_endpoint
  }
}