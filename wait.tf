resource "time_sleep" "wait_for_cluster" {
  depends_on = [
    module.eks.cluster_endpoint,
    null_resource.update_kubeconfig
  ]

  # Give EKS time to properly initialize and kubeconfig to be updated
  create_duration = "60s"
}