#############################
# EKS Cluster vpc cni addon #
#############################

module "irsa_vpc_cni" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.6.0"
  create_role                   = var.addon_create_vpc_cni ? true : false
  role_name                     = "${var.cluster_name}-vpc-cni"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = var.addon_create_vpc_cni && length(aws_iam_policy.vpc_cni.*) >= 1 ? concat(aws_iam_policy.vpc_cni.*.arn, ["arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]) : [""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-node"]
}

resource "aws_iam_policy" "vpc_cni" {
  count = var.addon_create_vpc_cni ? 1 : 0

  name        = "${var.cluster_name}-vpc-cni"
  description = "EKS cluster addon for VPC CNI ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.vpc_cni[0].json
  lifecycle {
    ignore_changes = [name, description]
  }
}

data "aws_iam_policy_document" "vpc_cni" {
  count = var.addon_create_vpc_cni ? 1 : 0

  statement {
    actions = [
      "sts:AssumeRoleWithWebIdentity",
      "sts:AssumeRole"
    ]
    effect = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${var.cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }
    resources = ["*"]

  }
}

resource "aws_eks_addon" "vpc_cni" {
  count = var.addon_create_vpc_cni ? 1 : 0

  cluster_name                = var.eks_cluster_id
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "PRESERVE"
  addon_version               = var.addon_vpc_cni_version
  service_account_role_arn    = module.irsa_vpc_cni.iam_role_arn

  lifecycle {
    ignore_changes = [cluster_name, addon_name]
  }
  tags = var.addon_tags
}

# Configure cni daemonset to support higher pod density https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html

# This null_resource can be removed, when "aws_eks_addon" resource support configuration for addons
# 0r this issue https://github.com/hashicorp/terraform-provider-kubernetes/issues/723 to patch deployment
resource "null_resource" "set_prefix_delegation_target" {
  depends_on = [aws_eks_addon.vpc_cni]

  provisioner "local-exec" {
    command = <<-EOT
      aws eks --region eu-west-2 update-kubeconfig --name ${var.cluster_name}
      kubectl set env daemonset aws-node -n kube-system ENABLE_PREFIX_DELEGATION=true
      kubectl set env daemonset aws-node -n kube-system WARM_PREFIX_TARGET=1
    EOT
  }
  triggers = {
    aws_eks_addon_cni_id = aws_eks_addon.vpc_cni[0].id
  }
}

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

  provisioner "local-exec" {
    command = <<-EOT
      aws eks --region eu-west-2 update-kubeconfig --name ${var.cluster_name}
      count=$(kubectl get nodes | grep Ready | wc -l) ; let count/=5 ; [ $count -lt 2 ] && count=2
      kubectl -n kube-system scale deployment coredns --replicas=$count
    EOT
  }
}
