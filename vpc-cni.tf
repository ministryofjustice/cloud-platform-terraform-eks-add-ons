#############################
# EKS Cluster vpc cni addon #
#############################

module "irsa_vpc_cni" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.44.0"
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
  resolve_conflicts_on_update = "OVERWRITE"
  addon_version               = var.addon_vpc_cni_version
  service_account_role_arn    = module.irsa_vpc_cni.iam_role_arn

  configuration_values = jsonencode({
    env = {
      # Configure cni daemonset to support higher pod density https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
      ENABLE_PREFIX_DELEGATION = "true"
      WARM_PREFIX_TARGET       = "1"
      ENABLE_SUBNET_DISCOVERY  = "false" # https://github.com/aws/amazon-vpc-cni-k8s/blob/8f9253e2e4452fe0e9e6a26a05675c8b7ae7a8fe/README.md?plain=1#L548
    }
  })

  lifecycle {
    ignore_changes = [cluster_name, addon_name]
  }
  tags = var.addon_tags
}

