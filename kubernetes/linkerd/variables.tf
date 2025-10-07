variable "namespace" {
  type        = string
  description = "Namespace onde o Linkerd será instalado"
  default     = "linkerd"
}

variable "linkerd_version" {
  type        = string
  description = "Versão do Linkerd a ser instalada"
  default     = "1.15.0"
}

variable "enable_viz" {
  type        = bool
  description = "Habilitar o Linkerd Viz (dashboard e métricas)"
  default     = true
}

variable "ca_cert_validity_hours" {
  type        = number
  description = "Validade do certificado raiz em horas (padrão: 10 anos)"
  default     = 87600 # 10 anos
}

variable "issuer_cert_validity_hours" {
  type        = number
  description = "Validade do certificado intermediário em horas (padrão: 1 ano)"
  default     = 8760 # 1 ano
}