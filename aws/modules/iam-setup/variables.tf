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

variable "deny_confidential_secrets_policy_name" {
  description = "Nome da policy que nega acesso a secrets confidenciais"
  type        = string
  default     = "DenyGetSecretValueForEnvConfidential"
}

variable "devops_policy_name" {
  description = "Nome da policy de acesso do DevOps"
  type        = string
  default     = "AllowedDevopsAccess"
}

variable "devops_n3_policy_name" {
  description = "Nome da policy de acesso do DevOps N3"
  type        = string
  default     = "AllowedDevopsAccessN3"
}

variable "dev_policy_name" {
  description = "Nome da policy de acesso do Dev"
  type        = string
  default     = "AllowedDevAccess"
}

variable "security_policy_name" {
  description = "Nome da policy de acesso de segurança"
  type        = string
  default     = "AllowedSecurityAccess"
}