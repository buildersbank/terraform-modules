variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "devops_group_principal_arn" {
  description = "ARN do grupo de usuários do DevOps"
  type        = string
}

variable "devops_n3_group_principal_arn" {
  description = "ARN do grupo de usuários do DevOps N3"
  type        = string
}

variable "dev_group_principal_arn" {
  description = "ARN do grupo de usuários do Dev"
  type        = string
}

variable "bucket_tfstate_arn" {
  description = "ARN do bucket do TFState"
  type        = string
  default     = ""
}