#############################
# EKS Cluster coredns addon #
#############################

resource "aws_eks_addon" "coredns" {
  count = var.addon_create_coredns ? 1 : 0

  cluster_name                = var.eks_cluster_id
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  addon_version               = var.addon_coredns_version

  configuration_values = jsonencode({
    replicaCount = 3
  })

  tags = var.addon_tags
}

# Increase number of coredns pods

# This null_resource can be removed when Kibana doesn't show "could not translate host name" events anymore
# https://kibana.cloud-platform.service.justice.gov.uk/_plugin/kibana/goto/4729982d70f22c38fce1a5e6ba2efa96
# 5 is very much a magic number obtained by manual editing and watching the graph at
# https://grafana.live.cloud-platform.service.justice.gov.uk/d/vkQ0UHxik/coredns?orgId=1
resource "null_resource" "more_coredns_pods" {
  depends_on = [aws_eks_addon.coredns]

  triggers = {
    always_run = var.addon_coredns_version
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks --region eu-west-2 update-kubeconfig --name ${var.cluster_name}
      count=$(kubectl get nodes | grep Ready | wc -l) ; let count/=5 ; [ $count -lt 3 ] && count=3
      kubectl -n kube-system scale deployment coredns --replicas=$count
    EOT
  }
}

