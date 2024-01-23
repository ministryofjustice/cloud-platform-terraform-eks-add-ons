
variable "eks_cluster_id" {
  description = "trigger for null resource using eks_cluster_id"
}

variable "cluster_name" {
  description = "Kubernetes cluster name - used to name (id) the auth0 resources"
}

variable "addon_create_vpc_cni" {
  description = "Create vpc_cni addon"
  type        = bool
  default     = true
}

variable "addon_create_kube_proxy" {
  description = "Create kube_proxy addon"
  type        = bool
  default     = true
}

variable "addon_create_coredns" {
  description = "Create coredns addon"
  type        = bool
  default     = true
}

variable "addon_vpc_cni_version" {
  default     = "v1.16.0-eksbuild.1"
  description = "Version for addon_create_vpc_cni"
  type = string
}

variable "addon_kube_proxy_version" {
  default     = "v1.25.15-eksbuild.2"
  description = "Version for addon_kube_proxy_version"
  type = string
}

variable "addon_coredns_version" {
  default     = "v1.9.3-eksbuild.10"
  description = "Version for addon_coredns_version"
  type = string
}

variable "cluster_oidc_issuer_url" {
  description = "Used to create the IAM OIDC role"
  type        = string
  default     = ""
}


variable "addon_tags" {
  default     = {}
  description = "Cluster addon tags"
  type        = map(string)
}
