# Outputs dos certificados TLS para uso no Linkerd
output "ca_certificate" {
  description = "Certificado raiz (Trust Anchor) do Linkerd"
  value       = tls_self_signed_cert.ca_cert.cert_pem
  sensitive   = false
}

output "ca_private_key" {
  description = "Chave privada do certificado raiz"
  value       = tls_private_key.ca_key.private_key_pem
  sensitive   = true
}

output "issuer_certificate" {
  description = "Certificado intermediário (Issuer) do Linkerd"
  value       = tls_locally_signed_cert.issuer_cert.cert_pem
  sensitive   = false
}

output "issuer_private_key" {
  description = "Chave privada do certificado intermediário"
  value       = tls_private_key.issuer_key.private_key_pem
  sensitive   = true
}

# Outputs para facilitar o uso com Helm
output "identity_trust_anchors_pem" {
  description = "Certificado raiz em formato PEM para uso com Helm"
  value       = tls_self_signed_cert.ca_cert.cert_pem
  sensitive   = false
}

output "identity_issuer_cert_pem" {
  description = "Certificado intermediário em formato PEM para uso com Helm"
  value       = tls_locally_signed_cert.issuer_cert.cert_pem
  sensitive   = false
}

output "identity_issuer_key_pem" {
  description = "Chave privada do certificado intermediário em formato PEM para uso com Helm"
  value       = tls_private_key.issuer_key.private_key_pem
  sensitive   = true
}
