resource "kubernetes_namespace" "linkerd" {
  metadata {
    name = var.namespace
    labels = {
      "linkerd.io/is-control-plane" = "true"
    }
  }
}

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

  depends_on = [ kubectl_manifest.linkerd_bundle ]
}

# Instalação do Linkerd Control Plane com certificados TLS customizados
resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  repository = "https://helm.linkerd.io/edge"
  chart      = "linkerd-control-plane"
  namespace  = var.namespace
  version    = var.linkerd_version

  create_namespace = true


  set {
    name  = "identity.externalCA"
    value = true
  }

  set {
    name  = "identity.issuer.scheme"
    value = "kubernetes.io/tls"
  }

  depends_on = [
    helm_release.linkerd_crds
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

resource "kubectl_manifest" "linkerd_service_account" {
  yaml_body = <<-YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cert-manager
  namespace: ${var.namespace}
  YAML
}

resource "kubectl_manifest" "linkerd_role" {
  yaml_body = <<-YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cert-manager-secret-creator
  namespace: ${var.namespace}
rules:
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["create", "get", "update", "patch"]
  YAML

  depends_on = [kubectl_manifest.linkerd_service_account]
}

resource "kubectl_manifest" "linkerd_role_binding" {
  yaml_body = <<-YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cert-manager-secret-creator-binding
  namespace: ${var.namespace}
subjects:
  - kind: ServiceAccount
    name: cert-manager
    namespace: ${var.namespace}
roleRef:
  kind: Role
  name: cert-manager-secret-creator
  apiGroup: rbac.authorization.k8s.io
  YAML

  depends_on = [kubectl_manifest.linkerd_role]
}