resource "aws_eks_access_entry" "devops_group" {
  count = var.devops_group_principal_arn != "" && var.cluster_name != "" ? 1 : 0
  cluster_name      = data.aws_eks_cluster.default[0].id
  principal_arn     = var.devops_group_principal_arn
  kubernetes_groups = ["devops-group"]
  type              = "STANDARD" 
}

resource "aws_eks_access_entry" "devops_n3_group" {
  count = var.devops_n3_group_principal_arn != "" && var.cluster_name != ""  ? 1 : 0
  cluster_name      = data.aws_eks_cluster.default[0].id
  principal_arn     = var.devops_n3_group_principal_arn
  kubernetes_groups = ["devops-n3-group"]
  type              = "STANDARD" 
}

resource "aws_eks_access_entry" "dev_group" {
  count = var.dev_group_principal_arn != "" && var.cluster_name != ""  ? 1 : 0
  cluster_name      = data.aws_eks_cluster.default[0].id
  principal_arn     = var.dev_group_principal_arn
  kubernetes_groups = ["dev-group"]
  type              = "STANDARD" 
}

resource "aws_eks_access_entry" "security_group" {
  count = var.security_group_principal_arn != "" && var.cluster_name != ""  ? 1 : 0
  cluster_name      = data.aws_eks_cluster.default[0].id
  principal_arn     = var.security_group_principal_arn
  kubernetes_groups = ["devops-group"]
  type              = "STANDARD" 
}