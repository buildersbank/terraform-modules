variable "cert_manager_version" {
  type        = string
  description = "Versão do cert-manager a ser instalada"
  default     = "v1.18.2"
}

variable "enable_trust_manager" {
  type        = bool
  description = "Habilitar o Trust Manager"
  default     = true
}

variable "trust_manager_version" {
  type        = string
  description = "Versão do trust-manager a ser instalada"
  default     = "v0.19.0"
}