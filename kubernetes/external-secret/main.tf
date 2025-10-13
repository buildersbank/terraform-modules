resource "helm_release" "external-secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = var.external_secret_version
  create_namespace = true
  namespace        = "external-secrets"
  cleanup_on_fail  = true
}

resource "kubectl_manifest" "external_secrets_clustersecretstore" {
  yaml_body = <<-YAML
apiVersion: external-secrets.io/v1
kind: ClusterSecretStore
metadata:
  name: secret-store
spec:
  provider:
    aws:
      service: SecretsManager
      role: ${aws_iam_role.external_secrets_role.arn}
      region: ${var.aws_region}
      auth:
        jwt:
          serviceAccountRef:
            name: external-secrets
            namespace: external-secrets
  YAML

  depends_on = [helm_release.external-secrets]
}

resource "kubectl_manifest" "external_secrets_service_account" {
  yaml_body = <<-YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    eks.amazonaws.com/role-arn: ${aws_iam_role.external_secrets_role.arn}
  name: external-secrets
  namespace: external-secrets
  YAML
}