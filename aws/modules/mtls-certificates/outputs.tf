output "ca_certificate_pem" {
  description = "CA certificate in PEM format"
  value       = tls_self_signed_cert.ca.cert_pem
}

output "ca_private_key_pem" {
  description = "CA private key in PEM format"
  value       = tls_private_key.ca.private_key_pem
  sensitive   = true
}

output "ca_certificate_file" {
  description = "Local path to CA certificate file"
  value       = local_file.ca_cert.filename
}

output "trust_store_bucket" {
  description = "S3 bucket name for trust store"
  value       = var.trust_store_bucket
}

output "trust_store_ca_s3_uri" {
  description = "S3 URI for CA certificate in trust store"
  value       = "s3://${var.trust_store_bucket}/${var.trust_store_ca_key}"
}

output "trust_store_ca_s3_key" {
  description = "S3 key for CA certificate"
  value       = aws_s3_object.ca_cert.key
}

# ===== CLIENT CERTIFICATE OUTPUTS =====

output "client_certificates" {
  description = "Client certificates information"
  value = {
    for name, cert in tls_locally_signed_cert.client : name => {
      certificate_pem = cert.cert_pem
      not_before      = cert.validity_start_time
      not_after       = cert.validity_end_time
    }
  }
}

output "client_private_keys" {
  description = "Client private keys"
  value = {
    for name, key in tls_private_key.client : name => {
      private_key_pem = key.private_key_pem
      public_key_pem  = key.public_key_pem
    }
  }
  sensitive = true
}

output "client_certificate_files" {
  description = "Local paths to client certificate files"
  value = {
    for name, file in local_file.client_cert : name => {
      certificate_file = file.filename
      private_key_file = local_sensitive_file.client_key[name].filename
      bundle_file      = local_file.client_bundle[name].filename
    }
  }
}

# ===== SUMMARY OUTPUTS =====

output "certificate_summary" {
  description = "Summary of all generated certificates"
  value = {
    ca = {
      common_name   = var.ca_config.common_name
      validity_days = var.ca_config.validity_days
      algorithm     = var.ca_key_algorithm
      key_size      = var.ca_key_size
      file_path     = local_file.ca_cert.filename
      s3_location   = "s3://${var.trust_store_bucket}/${var.trust_store_ca_key}"
    }
    clients = {
      for cert in var.client_certificates : cert.name => {
        common_name     = cert.common_name
        validity_days   = cert.validity_days
        certificate_file = "${var.output_path}/${cert.name}-certificate.pem"
        private_key_file = "${var.output_path}/${cert.name}-private-key.pem"
        bundle_file     = "${var.output_path}/${cert.name}-bundle.pem"
      }
    }
    trust_bundle_file = local_file.trust_bundle.filename
    output_directory  = var.output_path
  }
}

output "alb_trust_store_config" {
  description = "Configuration for ALB trust store"
  value = {
    s3_bucket = var.trust_store_bucket
    s3_key    = var.trust_store_ca_key
    s3_uri    = "s3://${var.trust_store_bucket}/${var.trust_store_ca_key}"
  }
}