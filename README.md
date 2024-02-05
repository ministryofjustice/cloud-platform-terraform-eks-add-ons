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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2.5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa_vpc_cni"></a> [irsa\_vpc\_cni](#module\_irsa\_vpc\_cni) | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | 4.6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.coredns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.kube_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_iam_policy.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [null_resource.more_coredns_pods](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.set_prefix_delegation_target](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_iam_policy_document.vpc_cni](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_coredns_version"></a> [addon\_coredns\_version](#input\_addon\_coredns\_version) | Version for addon\_coredns\_version | `string` | `"v1.9.3-eksbuild.11"` | no |
| <a name="input_addon_create_coredns"></a> [addon\_create\_coredns](#input\_addon\_create\_coredns) | Create coredns addon | `bool` | `true` | no |
| <a name="input_addon_create_kube_proxy"></a> [addon\_create\_kube\_proxy](#input\_addon\_create\_kube\_proxy) | Create kube\_proxy addon | `bool` | `true` | no |
| <a name="input_addon_create_vpc_cni"></a> [addon\_create\_vpc\_cni](#input\_addon\_create\_vpc\_cni) | Create vpc\_cni addon | `bool` | `true` | no |
| <a name="input_addon_kube_proxy_version"></a> [addon\_kube\_proxy\_version](#input\_addon\_kube\_proxy\_version) | Version for addon\_kube\_proxy\_version | `string` | `"v1.25.16-eksbuild.1"` | no |
| <a name="input_addon_tags"></a> [addon\_tags](#input\_addon\_tags) | Cluster addon tags | `map(string)` | `{}` | no |
| <a name="input_addon_vpc_cni_version"></a> [addon\_vpc\_cni\_version](#input\_addon\_vpc\_cni\_version) | Version for addon\_create\_vpc\_cni | `string` | `"v1.16.0-eksbuild.1"` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Kubernetes cluster name - used to name (id) the auth0 resources | `any` | n/a | yes |
| <a name="input_cluster_oidc_issuer_url"></a> [cluster\_oidc\_issuer\_url](#input\_cluster\_oidc\_issuer\_url) | Used to create the IAM OIDC role | `string` | `""` | no |
| <a name="input_eks_cluster_id"></a> [eks\_cluster\_id](#input\_eks\_cluster\_id) | trigger for null resource using eks\_cluster\_id | `any` | n/a | yes |

## Outputs

No outputs.

<!--- END_TF_DOCS --->

## Reading Material
https://github.com/aws/amazon-eks-add-ons-k8s

https://aws.amazon.com/blogs/containers/amazon-eks-add-ons-increases-pods-per-node-limits/


