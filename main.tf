#############################
# EKS Cluster vpc cni addon #
#############################

module "irsa_vpc_cni" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "4.6.0"
  create_role                   = var.addon_create_vpc_cni ? 1 : 0
  role_name                     = "${var.cluster_name}-vpc-cni"
  provider_url                  = var.cluster_oidc_issuer_url
  role_policy_arns              = [aws_iam_policy.vpc_cni.arn, "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:aws-node"]
}

resource "aws_iam_policy" "vpc_cni" {
  count = var.addon_create_vpc_cni ? 1 : 0

  name        = "${var.cluster_name}-vpc-cni"
  description = "EKS cluster addon for VPC CNI ${var.cluster_name}"
  policy      = data.aws_iam_policy_document.vpc_cni.json
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

  cluster_name      = var.eks_cluster_id
  addon_name        = "vpc-cni"
  resolve_conflicts = "OVERWRITE"
  addon_version     = var.addon_vpc_cni_version

  lifecycle {
    ignore_changes = [cluster_name, addon_name]
  }
  tags = var.addon_tags
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
