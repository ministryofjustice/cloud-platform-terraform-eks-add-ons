# cloud-platform-terraform-eks-add-ons

[![Releases](https://img.shields.io/github/release/ministryofjustice/cloud-platform-terraform-eks-add-ons/all.svg?style=flat-square)](https://github.com/ministryofjustice/cloud-platform-terraform-eks-add-ons/releases)

Terraform module that deploys cloud-platform eks-add-ons
## Usage

# For EKS clusters
```
module "aws_eks_addons" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-eks-add-ons=1.0.1"

  depends_on               = [module.eks]
  cluster_name             = terraform.workspace
  eks_cluster_id           = module.eks.cluster_id
  addon_create_vpc_cni     = true
  addon_create_kube_proxy  = false
  addon_create_coredns     = false
  cluster_oidc_issuer_url  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  addon_tags               = local.tags
}
```
<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.14 |

## Providers

| Name | Version |
|------|---------|
| helm | n/a |
| null | n/a |

## Modules

No Modules.

## Resources

| Name |
|------|
| [helm_release](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) |
| [null_resource](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) |

## Inputs

No input.

## Outputs

No output.

<!--- END_TF_DOCS --->

## Reading Material
https://github.com/aws/amazon-eks-add-ons-k8s

https://aws.amazon.com/blogs/containers/amazon-eks-add-ons-increases-pods-per-node-limits/


