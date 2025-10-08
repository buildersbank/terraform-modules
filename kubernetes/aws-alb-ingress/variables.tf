variable "namespace" {
  type        = string
  description = "Namespace onde o AWS ALB Ingress será instalado"
  default     = "ingress"
}

variable "aws_alb_ingress_version" {
  type        = string
  description = "Versão do AWS ALB Ingress a ser instalada"
  default     = "1.13.2"
}

variable "namespace_labels" {
  type        = map(string)
  description = "Labels para associar ao AWS ALB Ingress"
  default     = {}
}

variable "namespace_annotations" {
  type        = map(string)
  description = "Annotations para associar ao AWS ALB Ingress"
  default     = {}
}

variable "cluster_name" {
  type        = string
  description = "Nome do cluster"
}

variable "oidc_provider" {
  type        = string
  description = "OIDC provider"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}