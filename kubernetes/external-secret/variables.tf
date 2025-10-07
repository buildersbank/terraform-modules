variable "external_secret_version" {
  type        = string
  description = "Versão do external-secret a ser instalada"
  default     = "0.20.2"
}

variable "aws_region" {
  type        = string
  description = "Região AWS onde os secrets estão armazenados"
}

variable "cluster_name" {
  type        = string
  description = "Nome do cluster EKS"
}

variable "oidc_provider_arn" {
  type        = string
  description = "ARN do OIDC Provider do EKS"
}

variable "tags" {
  type        = map(string)
  description = "Tags para aplicar nos recursos"
  default     = {}
}