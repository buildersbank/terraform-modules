resource "helm_release" "linkerd_crds" {
  name       = "linkerd-crds"
  repository = "https://helm.linkerd.io/edge"
  chart      = "linkerd-crds"
  namespace  = var.namespace
  version    = var.linkerd_version

  create_namespace = true

  set {
    name  = "installGatewayAPI"
    value = "true"
  }
}

# Instalação do Linkerd Control Plane com certificados TLS customizados
resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  repository = "https://helm.linkerd.io/edge"
  chart      = "linkerd-control-plane"
  namespace  = var.namespace
  version    = var.linkerd_version

  create_namespace = true

  # Configuração dos certificados TLS gerados pelo Terraform
  set {
    name  = "identityTrustAnchorsPEM"
    value = tls_self_signed_cert.ca_cert.cert_pem
  }

  set {
    name  = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.issuer_cert.cert_pem
  }

  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_private_key.issuer_key.private_key_pem
  }

  depends_on = [
    helm_release.linkerd_crds,
    tls_self_signed_cert.ca_cert,
    tls_locally_signed_cert.issuer_cert
  ]
}

# Instalação do Linkerd Viz (dashboard e métricas) se habilitado
resource "helm_release" "linkerd_viz" {
  count = var.enable_viz ? 1 : 0

  name       = "linkerd-viz"
  repository = "https://helm.linkerd.io/edge"
  chart      = "linkerd-viz"
  namespace  = "${var.namespace}-viz"
  version    = var.linkerd_version

  create_namespace = true
  

  depends_on = [
    helm_release.linkerd_control_plane,
  ]
}