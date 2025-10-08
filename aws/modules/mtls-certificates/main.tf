resource "tls_private_key" "ca" {
  algorithm = var.ca_key_algorithm
  rsa_bits  = var.ca_key_size
}

# CA Certificate
resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

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

# S3 Bucket for Trust Store (if not exists)
resource "aws_s3_bucket" "trust_store" {
  count  = var.create_trust_store_bucket ? 1 : 0
  bucket = var.trust_store_bucket
}

resource "aws_s3_bucket_versioning" "trust_store" {
  count  = var.create_trust_store_bucket ? 1 : 0
  bucket = aws_s3_bucket.trust_store[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "trust_store" {
  count  = var.create_trust_store_bucket ? 1 : 0
  bucket = aws_s3_bucket.trust_store[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block all public access (CRITICAL for security)
resource "aws_s3_bucket_public_access_block" "trust_store" {
  count  = var.create_trust_store_bucket ? 1 : 0
  bucket = aws_s3_bucket.trust_store[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy for ALB Trust Store access
resource "aws_s3_bucket_policy" "trust_store" {
  count  = var.create_trust_store_bucket ? 1 : 0
  bucket = aws_s3_bucket.trust_store[0].id

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
        Resource = "${aws_s3_bucket.trust_store[0].arn}/*"
      },
      {
        Sid    = "DenyInsecureConnections"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.trust_store[0].arn,
          "${aws_s3_bucket.trust_store[0].arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.trust_store]
}

# Upload CA Certificate to Trust Store
resource "aws_s3_object" "ca_cert" {
  bucket       = var.trust_store_bucket
  key          = var.trust_store_ca_key
  content      = tls_self_signed_cert.ca.cert_pem
  content_type = "application/x-pem-file"

  depends_on = [aws_s3_bucket.trust_store]
}

# Client Private Keys
resource "tls_private_key" "client" {
  for_each  = { for cert in var.client_certificates : cert.name => cert }
  algorithm = var.client_key_algorithm
  rsa_bits  = var.client_key_size
}

# Client Certificate Requests
resource "tls_cert_request" "client" {
  for_each        = tls_private_key.client
  private_key_pem = each.value.private_key_pem

  subject {
    common_name         = var.client_certificates[index(var.client_certificates.*.name, each.key)].common_name
    organization        = var.ca_config.organization
    organizational_unit = var.ca_config.organizational_unit
    country             = var.ca_config.country
    province            = var.ca_config.state
    locality            = var.ca_config.locality
  }

  dns_names = lookup(var.client_certificates[index(var.client_certificates.*.name, each.key)], "dns_names", [])
}

# Client Certificates (signed by CA)
resource "tls_locally_signed_cert" "client" {
  for_each           = tls_cert_request.client
  cert_request_pem   = each.value.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = var.client_certificates[index(var.client_certificates.*.name, each.key)].validity_days * 24

  allowed_uses = [
    "client_auth",
    "digital_signature",
    "key_encipherment",
  ]
}

# Create output directory
resource "local_file" "output_directory" {
  content  = ""
  filename = "${var.output_path}/.gitkeep"
}

# Save CA Certificate locally
resource "local_file" "ca_cert" {
  content  = tls_self_signed_cert.ca.cert_pem
  filename = "${var.output_path}/ca-certificate.pem"
  
  depends_on = [local_file.output_directory]
}

# Save CA Private Key locally (for backup/emergency)
resource "local_sensitive_file" "ca_key" {
  content  = tls_private_key.ca.private_key_pem
  filename = "${var.output_path}/ca-private-key.pem"
  
  depends_on = [local_file.output_directory]
}

# Save Client Certificates locally
resource "local_file" "client_cert" {
  for_each = tls_locally_signed_cert.client
  content  = each.value.cert_pem
  filename = "${var.output_path}/${each.key}-certificate.pem"
  
  depends_on = [local_file.output_directory]
}

# Save Client Private Keys locally
resource "local_sensitive_file" "client_key" {
  for_each = tls_private_key.client
  content  = each.value.private_key_pem
  filename = "${var.output_path}/${each.key}-private-key.pem"
  
  depends_on = [local_file.output_directory]
}

# Create client certificate bundles (cert + key)
resource "local_file" "client_bundle" {
  for_each = tls_locally_signed_cert.client
  content = join("\n", [
    tls_locally_signed_cert.client[each.key].cert_pem,
    tls_private_key.client[each.key].private_key_pem
  ])
  filename = "${var.output_path}/${each.key}-bundle.pem"
  
  depends_on = [local_file.output_directory]
}

# Create trust bundle (CA + intermediate if any)
resource "local_file" "trust_bundle" {
  content  = tls_self_signed_cert.ca.cert_pem
  filename = "${var.output_path}/trust-bundle.pem"
  
  depends_on = [local_file.output_directory]
}