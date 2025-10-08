# ===== OUTPUTS DA CA =====

output "ca_certificate_pem" {
  description = "Certificado da CA em formato PEM"
  value       = var.create_ca ? tls_self_signed_cert.ca[0].cert_pem : data.aws_s3_object.existing_ca_certificate[0].body
}

output "ca_private_key_pem" {
  description = "Chave privada da CA em formato PEM"
  value       = var.create_ca ? tls_private_key.ca[0].private_key_pem : data.aws_s3_object.existing_ca_private_key[0].body
  sensitive   = true
}

output "ca_storage_bucket" {
  description = "Nome do bucket S3 para armazenar a CA"
  value       = var.ca_storage_bucket
}

output "ca_certificate_s3_uri" {
  description = "URI S3 para o certificado da CA"
  value       = "s3://${var.ca_storage_bucket}/${var.ca_certificate_key}"
}

output "ca_private_key_s3_uri" {
  description = "URI S3 para a chave privada da CA"
  value       = "s3://${var.ca_storage_bucket}/${var.ca_private_key_key}"
  sensitive   = true
}

# ===== OUTPUTS DOS CERTIFICADOS ASSINADOS =====

output "signed_certificates" {
  description = "Certificados assinados"
  value = {
    for name, cert in tls_locally_signed_cert.signed_certificates : name => {
      certificate_pem = cert.cert_pem
      not_before      = cert.validity_start_time
      not_after       = cert.validity_end_time
    }
  }
}

output "signed_certificates_s3_uris" {
  description = "URIs S3 para os certificados assinados"
  value = {
    for name, obj in aws_s3_object.signed_certificate : name => {
      certificate_uri = "s3://${obj.bucket}/${obj.key}"
      bundle_uri      = "s3://${aws_s3_object.certificate_bundle[name].bucket}/${aws_s3_object.certificate_bundle[name].key}"
    }
  }
}

output "signed_certificates_bucket" {
  description = "Nome do bucket S3 para certificados assinados"
  value       = var.signed_certificates_bucket
}

# ===== OUTPUTS DO TRUSTSTORE =====

output "truststore_bucket" {
  description = "Nome do bucket S3 para o truststore"
  value       = var.truststore_bucket
}

output "ca_certificate_truststore_s3_uri" {
  description = "URI S3 para o certificado da CA no truststore"
  value       = "s3://${var.truststore_bucket}/${var.truststore_ca_key}"
}

output "trust_bundle_s3_uri" {
  description = "URI S3 para o trust bundle"
  value       = "s3://${var.truststore_bucket}/${var.trust_bundle_key}"
}

output "alb_truststore_config" {
  description = "Configuração do truststore para ALB"
  value = {
    s3_bucket = var.truststore_bucket
    s3_key    = var.truststore_ca_key
    s3_uri    = "s3://${var.truststore_bucket}/${var.truststore_ca_key}"
  }
}

# ===== OUTPUTS DE EXPORTAÇÃO =====

output "exported_certificates_s3_uris" {
  description = "URIs S3 para os certificados exportados"
  value = {
    for name, obj in aws_s3_object.exported_certificate : name => {
      certificate_uri = "s3://${obj.bucket}/${obj.key}"
      bundle_uri      = "s3://${aws_s3_object.exported_bundle[name].bucket}/${aws_s3_object.exported_bundle[name].key}"
    }
  }
}

output "export_bucket" {
  description = "Nome do bucket S3 para exportação"
  value       = var.export_bucket
}

output "export_metadata_s3_uri" {
  description = "URI S3 para os metadados de exportação"
  value       = "s3://${var.export_bucket}/${var.export_prefix}/metadata.json"
}

# ===== OUTPUTS DE RESUMO =====

output "mtls_summary" {
  description = "Resumo completo do fluxo mTLS"
  value = {
    ca = {
      created = var.create_ca
      common_name = var.ca_config.common_name
      validity_days = var.ca_config.validity_days
      algorithm = var.ca_key_algorithm
      key_size = var.ca_key_size
      certificate_s3_uri = "s3://${var.ca_storage_bucket}/${var.ca_certificate_key}"
      private_key_s3_uri = "s3://${var.ca_storage_bucket}/${var.ca_private_key_key}"
    }
    signed_certificates = {
      total_count = length(var.csr_requests)
      bucket = var.signed_certificates_bucket
      certificates = {
        for name, cert in tls_locally_signed_cert.signed_certificates : name => {
          validity_days = var.csr_requests[name].validity_days
          allowed_uses = var.csr_requests[name].allowed_uses
          certificate_s3_uri = "s3://${var.signed_certificates_bucket}/${var.signed_certificates_prefix}/${name}/certificate.pem"
          bundle_s3_uri = "s3://${var.signed_certificates_bucket}/${var.signed_certificates_prefix}/${name}/bundle.pem"
        }
      }
    }
    truststore = {
      bucket = var.truststore_bucket
      ca_certificate_uri = "s3://${var.truststore_bucket}/${var.truststore_ca_key}"
      trust_bundle_uri = "s3://${var.truststore_bucket}/${var.trust_bundle_key}"
      additional_certificates_count = length(var.additional_trusted_certificates)
    }
    exports = {
      bucket = var.export_bucket
      prefix = var.export_prefix
      certificates_count = length(var.certificates_to_export)
      metadata_uri = "s3://${var.export_bucket}/${var.export_prefix}/metadata.json"
    }
    environment = var.environment
  }
}

output "local_backup_files" {
  description = "Arquivos de backup local (se habilitado)"
  value = var.create_local_backup ? {
    ca_certificate_file = local_file.ca_certificate_local[0].filename
    ca_private_key_file = local_sensitive_file.ca_private_key_local[0].filename
    trust_bundle_file = local_file.trust_bundle_local[0].filename
    signed_certificates = {
      for name, file in local_file.signed_certificate_local : name => file.filename
    }
  } : null
}
