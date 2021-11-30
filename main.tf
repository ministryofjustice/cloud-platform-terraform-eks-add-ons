#############################
# EKS Cluster vpc cni addon #
#############################

module "irsa_vpc_cni" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.6.0"
  create_role                   = true
  role_name                     = "${var.cluster_name}-vpc-cni"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.vpc_cni.arn, "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-node"]
}

resource "aws_iam_policy" "vpc_cni" {
  name        = "${var.cluster_name}-vpc-cni"
  description = "EKS cluster addon for VPC CNI ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.vpc_cni.json
  lifecycle {
    ignore_changes = [name, description]
  }
}

data "aws_iam_policy_document" "vpc_cni" {
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

  cluster_name      = var.eks_cluster_id
  addon_name        = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
  addon_version     = var.addon_vpc_cni_version

  lifecycle {
    ignore_changes = [cluster_name, addon_name]
  }
  tags = var.addon_tags
}

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

  cluster_name      = var.eks_cluster_id
  addon_name        = "kube-proxy"
  resolve_conflicts = "OVERWRITE"
  addon_version     = var.addon_kube_proxy_version

  tags = var.addon_tags
}

#############################
# EKS Cluster coredns addon #
#############################

resource "aws_eks_addon" "coredns" {
  count = var.addon_create_coredns ? 1 : 0

  cluster_name      = var.eks_cluster_id
  addon_name        = "coredns"
  resolve_conflicts = "OVERWRITE"
  addon_version     = var.addon_coredns_version

  tags = var.addon_tags
}
