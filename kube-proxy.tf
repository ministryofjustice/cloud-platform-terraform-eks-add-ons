################################
# EKS Cluster kube proxy addon #
################################

resource "aws_eks_addon" "kube_proxy" {
  count = var.addon_create_kube_proxy ? 1 : 0

  cluster_name                = var.eks_cluster_id
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  addon_version               = var.addon_kube_proxy_version

  tags = var.addon_tags
}


