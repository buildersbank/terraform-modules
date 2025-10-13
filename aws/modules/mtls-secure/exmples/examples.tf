# ===== EXEMPLO 1: FLUXO COMPLETO (CRIAR CA + ASSINAR CSRs) =====

module "mtls_complete" {
  source = "./modules/mtls-secure"

  environment = "production"

  # ===== CONFIGURAÇÃO DA CA =====
  create_ca = true
  ca_config = {
    common_name         = "MyCompany Root CA"
    organization        = "MyCompany Inc"
    organizational_unit = "IT Department"
    country             = "BR"
    state               = "SP"
    locality            = "São Paulo"
    validity_days       = 3650  # 10 anos
  }

  ca_key_algorithm = "RSA"
  ca_key_size      = 4096

  ca_storage_bucket = "mycompany-mtls-ca-storage"
  create_ca_storage_bucket = true

  # ===== CSRs PARA ASSINAR =====
  csr_requests = {
    "client-app-1" = {
      csr_pem       = var.client_app_1_csr_pem
      validity_days = 365
      allowed_uses  = ["client_auth", "digital_signature", "key_encipherment"]
    }
    "client-app-2" = {
      csr_pem       = var.client_app_2_csr_pem
      validity_days = 365
      allowed_uses  = ["client_auth", "digital_signature", "key_encipherment"]
    }
  }

  signed_certificates_bucket = "mycompany-mtls-signed-certs"
  create_signed_certificates_bucket = true

  # ===== TRUSTSTORE =====
  truststore_bucket = "mycompany-mtls-truststore"
  create_truststore_bucket = true

  # ===== EXPORTAÇÃO =====
  certificates_to_export = {
    "client-app-1" = "pem"
    "client-app-2" = "pem"
  }

  export_bucket = "mycompany-mtls-exports"
  create_export_bucket = true

  # ===== SEGURANÇA =====
  create_local_backup = false  # Por segurança, não criar backup local
}

# ===== EXEMPLO 2: USAR CA EXISTENTE + ASSINAR CSRs =====

module "mtls_existing_ca" {
  source = "./modules/mtls-secure"

  environment = "production"

  # ===== USAR CA EXISTENTE =====
  create_ca = false
  ca_storage_bucket = "existing-ca-storage"
  ca_certificate_key = "ca/certificate.pem"
  ca_private_key_key = "ca/private-key.pem"

  # ===== CSRs PARA ASSINAR =====
  csr_requests = {
    "new-client" = {
      csr_pem       = var.new_client_csr_pem
      validity_days = 365
      allowed_uses  = ["client_auth", "digital_signature"]
    }
  }

  signed_certificates_bucket = "mycompany-mtls-signed-certs"
  create_signed_certificates_bucket = false  # Bucket já existe

  # ===== TRUSTSTORE =====
  truststore_bucket = "mycompany-mtls-truststore"
  create_truststore_bucket = false  # Bucket já existe

  # ===== EXPORTAÇÃO =====
  certificates_to_export = {
    "new-client" = "pem"
  }

  export_bucket = "mycompany-mtls-exports"
  create_export_bucket = false  # Bucket já existe
}

# ===== EXEMPLO 3: APENAS CONFIGURAR TRUSTSTORE =====

module "mtls_truststore_only" {
  source = "./modules/mtls-secure"

  environment = "production"

  # ===== USAR CA EXISTENTE =====
  create_ca = false
  ca_storage_bucket = "existing-ca-storage"
  ca_certificate_key = "ca/certificate.pem"
  ca_private_key_key = "ca/private-key.pem"

  # ===== SEM CSRs =====
  csr_requests = {}
  signed_certificates_bucket = "dummy-bucket"  # Não será usado
  create_signed_certificates_bucket = false

  # ===== APENAS TRUSTSTORE =====
  truststore_bucket = "mycompany-mtls-truststore"
  create_truststore_bucket = true

  # Certificados adicionais para confiar
  additional_trusted_certificates = {
    "external-ca-1" = {
      certificate_pem = var.external_ca_1_certificate
    }
    "external-ca-2" = {
      certificate_pem = var.external_ca_2_certificate
    }
  }

  # ===== SEM EXPORTAÇÃO =====
  certificates_to_export = {}
  export_bucket = "dummy-export-bucket"  # Não será usado
  create_export_bucket = false
}

# ===== VARIÁVEIS =====

variable "client_app_1_csr_pem" {
  description = "CSR PEM do cliente app 1"
  type        = string
}

variable "client_app_2_csr_pem" {
  description = "CSR PEM do cliente app 2"
  type        = string
}

variable "new_client_csr_pem" {
  description = "CSR PEM do novo cliente"
  type        = string
}

variable "external_ca_1_certificate" {
  description = "Certificado da CA externa 1"
  type        = string
  default     = ""
}

variable "external_ca_2_certificate" {
  description = "Certificado da CA externa 2"
  type        = string
  default     = ""
}

# ===== OUTPUTS =====

output "complete_flow_summary" {
  description = "Resumo do fluxo completo"
  value       = module.mtls_complete.mtls_summary
}

output "truststore_config" {
  description = "Configuração do truststore para ALB"
  value       = module.mtls_complete.alb_truststore_config
}

output "exported_certificates" {
  description = "Certificados exportados"
  value       = module.mtls_complete.exported_certificates_s3_uris
}
