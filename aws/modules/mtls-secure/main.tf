# ===== GERAÇÃO DA CA =====

resource "tls_private_key" "ca" {
  count     = var.create_ca ? 1 : 0
  algorithm = var.ca_key_algorithm
  rsa_bits  = var.ca_key_size
}

resource "tls_self_signed_cert" "ca" {
  count           = var.create_ca ? 1 : 0
  private_key_pem = tls_private_key.ca[0].private_key_pem

  subject {
    common_name         = var.ca_config.common_name
    organization        = var.ca_config.organization
    organizational_unit = var.ca_config.organizational_unit
    country             = var.ca_config.country
    province            = var.ca_config.state
    locality            = var.ca_config.locality
  }

  validity_period_hours = var.ca_config.validity_days * 24
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
    "key_encipherment",
  ]
}

# ===== STORAGE DA CA =====

resource "aws_s3_bucket" "ca_storage" {
  count  = var.create_ca && var.create_ca_storage_bucket ? 1 : 0
  bucket = var.ca_storage_bucket
}

resource "aws_s3_bucket_versioning" "ca_storage" {
  count  = var.create_ca && var.create_ca_storage_bucket ? 1 : 0
  bucket = aws_s3_bucket.ca_storage[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ca_storage" {
  count  = var.create_ca && var.create_ca_storage_bucket ? 1 : 0
  bucket = aws_s3_bucket.ca_storage[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "ca_storage" {
  count  = var.create_ca && var.create_ca_storage_bucket ? 1 : 0
  bucket = aws_s3_bucket.ca_storage[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload da CA para storage
resource "aws_s3_object" "ca_certificate" {
  count          = var.create_ca ? 1 : 0
  bucket         = var.ca_storage_bucket
  key            = var.ca_certificate_key
  content        = tls_self_signed_cert.ca[0].cert_pem
  content_type   = "application/x-pem-file"
}

resource "aws_s3_object" "ca_private_key" {
  count          = var.create_ca ? 1 : 0
  bucket         = var.ca_storage_bucket
  key            = var.ca_private_key_key
  content        = tls_private_key.ca[0].private_key_pem
  content_type   = "application/x-pem-file"
}

# ===== DATA SOURCES PARA CA EXISTENTE =====

data "aws_s3_object" "existing_ca_certificate" {
  count  = !var.create_ca ? 1 : 0
  bucket = var.ca_storage_bucket
  key    = var.ca_certificate_key
}

data "aws_s3_object" "existing_ca_private_key" {
  count  = !var.create_ca ? 1 : 0
  bucket = var.ca_storage_bucket
  key    = var.ca_private_key_key
}

# ===== ASSINATURA DE CSRs =====

locals {
  # Usar CA criada ou existente
  ca_certificate_pem = var.create_ca ? tls_self_signed_cert.ca[0].cert_pem : data.aws_s3_object.existing_ca_certificate[0].body
  ca_private_key_pem = var.create_ca ? tls_private_key.ca[0].private_key_pem : data.aws_s3_object.existing_ca_private_key[0].body
}

resource "tls_locally_signed_cert" "signed_certificates" {
  for_each = var.csr_requests

  cert_request_pem   = each.value.csr_pem
  ca_private_key_pem = local.ca_private_key_pem
  ca_cert_pem        = local.ca_certificate_pem

  validity_period_hours = each.value.validity_days * 24
  allowed_uses          = each.value.allowed_uses
}

# ===== STORAGE DOS CERTIFICADOS ASSINADOS =====

resource "aws_s3_bucket" "signed_certificates_storage" {
  count  = var.create_signed_certificates_bucket ? 1 : 0
  bucket = var.signed_certificates_bucket
}

resource "aws_s3_bucket_versioning" "signed_certificates_storage" {
  count  = var.create_signed_certificates_bucket ? 1 : 0
  bucket = aws_s3_bucket.signed_certificates_storage[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "signed_certificates_storage" {
  count  = var.create_signed_certificates_bucket ? 1 : 0
  bucket = aws_s3_bucket.signed_certificates_storage[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "signed_certificates_storage" {
  count  = var.create_signed_certificates_bucket ? 1 : 0
  bucket = aws_s3_bucket.signed_certificates_storage[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Upload dos certificados assinados
resource "aws_s3_object" "signed_certificate" {
  for_each = tls_locally_signed_cert.signed_certificates

  bucket       = var.signed_certificates_bucket
  key          = "${var.signed_certificates_prefix}/${each.key}/certificate.pem"
  content      = each.value.cert_pem
  content_type = "application/x-pem-file"
}

# Certificado + CA bundle
resource "aws_s3_object" "certificate_bundle" {
  for_each = tls_locally_signed_cert.signed_certificates

  bucket       = var.signed_certificates_bucket
  key          = "${var.signed_certificates_prefix}/${each.key}/bundle.pem"
  content = join("\n", [
    each.value.cert_pem,
    local.ca_certificate_pem
  ])
  content_type = "application/x-pem-file"
}

# ===== TRUSTSTORE =====

resource "aws_s3_bucket" "truststore" {
  count  = var.create_truststore_bucket ? 1 : 0
  bucket = var.truststore_bucket
}

resource "aws_s3_bucket_versioning" "truststore" {
  count  = var.create_truststore_bucket ? 1 : 0
  bucket = aws_s3_bucket.truststore[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "truststore" {
  count  = var.create_truststore_bucket ? 1 : 0
  bucket = aws_s3_bucket.truststore[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "truststore" {
  count  = var.create_truststore_bucket ? 1 : 0
  bucket = aws_s3_bucket.truststore[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Política para acesso do ALB ao truststore
resource "aws_s3_bucket_policy" "truststore" {
  count  = var.create_truststore_bucket ? 1 : 0
  bucket = aws_s3_bucket.truststore[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowALBTrustStoreAccess"
        Effect = "Allow"
        Principal = {
          Service = "elasticloadbalancing.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion"
        ]
        Resource = "${aws_s3_bucket.truststore[0].arn}/*"
      },
      {
        Sid    = "DenyInsecureConnections"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.truststore[0].arn,
          "${aws_s3_bucket.truststore[0].arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.truststore]
}

# Upload da CA para o truststore
resource "aws_s3_object" "truststore_ca" {
  bucket       = var.truststore_bucket
  key          = var.truststore_ca_key
  content      = local.ca_certificate_pem
  content_type = "application/x-pem-file"
}

# Trust bundle (CA + certificados adicionais)
locals {
  trust_bundle_content = join("\n", concat(
    [local.ca_certificate_pem],
    [for cert in var.additional_trusted_certificates : cert.certificate_pem]
  ))
}

resource "aws_s3_object" "trust_bundle" {
  bucket       = var.truststore_bucket
  key          = var.trust_bundle_key
  content      = local.trust_bundle_content
  content_type = "application/x-pem-file"
}

# ===== EXPORTAÇÃO DE CERTIFICADOS =====

resource "aws_s3_bucket" "export_bucket" {
  count  = var.create_export_bucket ? 1 : 0
  bucket = var.export_bucket
}

resource "aws_s3_bucket_versioning" "export_bucket" {
  count  = var.create_export_bucket ? 1 : 0
  bucket = aws_s3_bucket.export_bucket[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "export_bucket" {
  count  = var.create_export_bucket ? 1 : 0
  bucket = aws_s3_bucket.export_bucket[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "export_bucket" {
  count  = var.create_export_bucket ? 1 : 0
  bucket = aws_s3_bucket.export_bucket[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Exportar certificados selecionados
resource "aws_s3_object" "exported_certificate" {
  for_each = var.certificates_to_export

  bucket       = var.export_bucket
  key          = "${var.export_prefix}/${each.key}/certificate.pem"
  content      = tls_locally_signed_cert.signed_certificates[each.key].cert_pem
  content_type = "application/x-pem-file"
}

resource "aws_s3_object" "exported_bundle" {
  for_each = var.certificates_to_export

  bucket       = var.export_bucket
  key          = "${var.export_prefix}/${each.key}/bundle.pem"
  content = join("\n", [
    tls_locally_signed_cert.signed_certificates[each.key].cert_pem,
    local.ca_certificate_pem
  ])
  content_type = "application/x-pem-file"
}

# Metadados de exportação
resource "aws_s3_object" "export_metadata" {
  bucket       = var.export_bucket
  key          = "${var.export_prefix}/metadata.json"
  content = jsonencode({
    export_timestamp = timestamp()
    environment      = var.environment
    certificates = {
      for name, cert in var.certificates_to_export : name => {
        certificate_s3_uri = "s3://${var.export_bucket}/${var.export_prefix}/${name}/certificate.pem"
        bundle_s3_uri      = "s3://${var.export_bucket}/${var.export_prefix}/${name}/bundle.pem"
        validity_days      = var.csr_requests[name].validity_days
        allowed_uses       = var.csr_requests[name].allowed_uses
      }
    }
  })
  content_type = "application/json"
}

# ===== BACKUP LOCAL (OPCIONAL) =====

resource "local_file" "output_directory" {
  count    = var.create_local_backup ? 1 : 0
  content  = ""
  filename = "${var.local_backup_path}/.gitkeep"
}

resource "local_file" "ca_certificate_local" {
  count    = var.create_local_backup ? 1 : 0
  content  = local.ca_certificate_pem
  filename = "${var.local_backup_path}/ca-certificate.pem"
  
  depends_on = [local_file.output_directory]
}

resource "local_sensitive_file" "ca_private_key_local" {
  count    = var.create_local_backup ? 1 : 0
  content  = local.ca_private_key_pem
  filename = "${var.local_backup_path}/ca-private-key.pem"
  
  depends_on = [local_file.output_directory]
}

resource "local_file" "signed_certificate_local" {
  for_each = var.create_local_backup ? tls_locally_signed_cert.signed_certificates : {}
  content  = each.value.cert_pem
  filename = "${var.local_backup_path}/${each.key}-certificate.pem"
  
  depends_on = [local_file.output_directory]
}

resource "local_file" "trust_bundle_local" {
  count    = var.create_local_backup ? 1 : 0
  content  = local.trust_bundle_content
  filename = "${var.local_backup_path}/trust-bundle.pem"
  
  depends_on = [local_file.output_directory]
}
