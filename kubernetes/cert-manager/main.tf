resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = var.cert_manager_version
  create_namespace = true
  namespace        = "cert-manager"
  cleanup_on_fail  = true

  set {
    name  = "crds.enabled"
    value = "true"
  }

  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }

  # Configurações de segurança
  set {
    name  = "securityContext.runAsNonRoot"
    value = "true"
  }

  set {
    name  = "securityContext.runAsUser"
    value = "1000"
  }

  set {
    name  = "securityContext.fsGroup"
    value = "1000"
  }

  # Configurações de recursos
  set {
    name  = "resources.limits.cpu"
    value = "100m"
  }

  set {
    name  = "resources.limits.memory"
    value = "128Mi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "128Mi"
  }
}

resource "helm_release" "trust-manager" {
  count = var.enable_trust_manager ? 1 : 0
  name             = "trust-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "trust-manager"
  version          = var.trust_manager_version
  create_namespace = true
  namespace        = "cert-manager"
  cleanup_on_fail  = true
  
}