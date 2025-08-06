data "aws_eks_cluster" "default" {
  count = var.cluster_name != "" ? 1 : 0
  name = var.cluster_name
}
