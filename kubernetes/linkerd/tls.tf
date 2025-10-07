# Certificado raiz (Trust Anchor) para o Linkerd
resource "tls_private_key" "ca_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "ca_cert" {
  private_key_pem = tls_private_key.ca_key.private_key_pem

  subject {
    common_name  = "root.linkerd.cluster.local"
    organization = "Linkerd"
  }

  validity_period_hours = var.ca_cert_validity_hours

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]

  is_ca_certificate = true
}

# Certificado intermediário (Issuer) para assinar CSRs dos proxies
resource "tls_private_key" "issuer_key" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "issuer_csr" {
  private_key_pem = tls_private_key.issuer_key.private_key_pem

  subject {
    common_name  = "identity.linkerd.cluster.local"
    organization = "Linkerd"
  }
}

resource "tls_locally_signed_cert" "issuer_cert" {
  cert_request_pem   = tls_cert_request.issuer_csr.cert_request_pem
  ca_private_key_pem = tls_private_key.ca_key.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca_cert.cert_pem

  validity_period_hours = var.issuer_cert_validity_hours

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]

  is_ca_certificate = true
}

resource "kubernetes_secret" "linkerd_ca_cert" {
  metadata {
    name = "linkerd-ca-cert"
    namespace = var.namespace
  }

  data = {
    "ca.crt" = tls_self_signed_cert.ca_cert.cert_pem
  }
}

resource "kubernetes_secret" "linkerd_issuer_cert" {
  metadata {
    name = "linkerd-issuer-cert"
    namespace = var.namespace
  }

  data = {
    "issuer.crt" = tls_locally_signed_cert.issuer_cert.cert_pem
  }
}

resource "kubernetes_secret" "linkerd_issuer_key" {
  metadata {
    name = "linkerd-issuer-key"
    namespace = var.namespace
  }

  data = {
    "issuer.key" = tls_private_key.issuer_key.private_key_pem
  }
}