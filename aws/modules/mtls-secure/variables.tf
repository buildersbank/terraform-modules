# ===== CONFIGURAÇÃO DA CA =====

variable "create_ca" {
  description = "Se deve criar uma nova CA ou usar uma existente"
  type        = bool
  default     = true
}

variable "ca_config" {
  description = "Configuração da Autoridade Certificadora"
  type = object({
    common_name         = string
    organization        = string
    organizational_unit = string
    country             = string
    state               = string
    locality            = string
    validity_days       = number
  })
  
  validation {
    condition     = var.ca_config.validity_days > 0
    error_message = "Dias de validade da CA devem ser maiores que 0."
  }
}

variable "ca_key_algorithm" {
  description = "Algoritmo para a chave privada da CA"
  type        = string
  default     = "RSA"
  
  validation {
    condition     = contains(["RSA", "ECDSA"], var.ca_key_algorithm)
    error_message = "Algoritmo da chave CA deve ser RSA ou ECDSA."
  }
}

variable "ca_key_size" {
  description = "Tamanho da chave privada da CA (bits RSA)"
  type        = number
  default     = 4096
  
  validation {
    condition     = contains([2048, 3072, 4096], var.ca_key_size)
    error_message = "Tamanho da chave CA deve ser 2048, 3072, ou 4096."
  }
}

variable "ca_storage_bucket" {
  description = "Nome do bucket S3 para armazenar a CA"
  type        = string
}

variable "ca_certificate_key" {
  description = "Chave S3 para o certificado da CA"
  type        = string
  default     = "ca/certificate.pem"
}

variable "ca_private_key_key" {
  description = "Chave S3 para a chave privada da CA"
  type        = string
  default     = "ca/private-key.pem"
}

variable "create_ca_storage_bucket" {
  description = "Se deve criar o bucket S3 para armazenar a CA"
  type        = bool
  default     = true
}

# ===== CONFIGURAÇÃO DE CSRs =====

variable "csr_requests" {
  description = "Mapa de CSRs para assinar"
  type = map(object({
    csr_pem       = string
    validity_days = number
    allowed_uses  = list(string)
  }))
  default = {}
}

variable "signed_certificates_bucket" {
  description = "Nome do bucket S3 para armazenar certificados assinados"
  type        = string
}

variable "signed_certificates_prefix" {
  description = "Prefixo para os certificados assinados no S3"
  type        = string
  default     = "signed-certificates"
}

variable "create_signed_certificates_bucket" {
  description = "Se deve criar o bucket S3 para certificados assinados"
  type        = bool
  default     = true
}

# ===== CONFIGURAÇÃO DO TRUSTSTORE =====

variable "truststore_bucket" {
  description = "Nome do bucket S3 para o truststore"
  type        = string
}

variable "truststore_ca_key" {
  description = "Chave S3 para o certificado da CA no truststore"
  type        = string
  default     = "ca/ca-certificate.pem"
}

variable "trust_bundle_key" {
  description = "Chave S3 para o trust bundle"
  type        = string
  default     = "trust-bundle.pem"
}

variable "create_truststore_bucket" {
  description = "Se deve criar o bucket S3 para o truststore"
  type        = bool
  default     = true
}

variable "additional_trusted_certificates" {
  description = "Certificados adicionais para incluir no truststore"
  type = map(object({
    certificate_pem = string
  }))
  default = {}
}

# ===== CONFIGURAÇÃO DE EXPORTAÇÃO =====

variable "certificates_to_export" {
  description = "Mapa de certificados para exportar"
  type        = map(string)
  default     = {}
}

variable "export_bucket" {
  description = "Nome do bucket S3 para exportar os certificados"
  type        = string
}

variable "export_prefix" {
  description = "Prefixo para os certificados exportados no S3"
  type        = string
  default     = "exported-certificates"
}

variable "create_export_bucket" {
  description = "Se deve criar o bucket S3 para exportação"
  type        = bool
  default     = true
}

# ===== CONFIGURAÇÃO GERAL =====

variable "create_local_backup" {
  description = "Se deve criar backup local dos arquivos"
  type        = bool
  default     = false
}

variable "local_backup_path" {
  description = "Caminho local para salvar os arquivos"
  type        = string
  default     = "./mtls-backup"
}

variable "environment" {
  description = "Nome do ambiente"
  type        = string
}
