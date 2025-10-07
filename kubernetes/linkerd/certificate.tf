resource "kubectl_manifest" "linkerd_issuer" {
  yaml_body = <<-YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: linkerd-trust-root-issuer
  namespace: cert-manager
spec:
  selfSigned: {}
  YAML

  depends_on = [kubectl_manifest.linkerd_role_binding]
}

resource "kubectl_manifest" "linkerd_certificate" {
  yaml_body = <<-YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  # This is the name of the Certificate resource, but the Secret
  # we save the certificate into can be different.
  name: linkerd-trust-anchor
  namespace: cert-manager
spec:
  # This tells cert-manager which issuer to use for this Certificate:
  # in this case, the Issuer named linkerd-trust-root-issuer.
  issuerRef:
    kind: Issuer
    name: linkerd-trust-root-issuer

  # The issued certificate will be saved in this Secret
  secretName: linkerd-trust-anchor

  # These are details about the certificate to be issued: check
  # out the cert-manager docs for more, but realize that setting
  # the private key's rotationPolicy to Always is _very_ important,
  # and that for Linkerd you _must_ set isCA to true!
  isCA: true
  commonName: root.linkerd.cluster.local
  # This is a one-year duration, rotating two months before expiry.
  # Feel free to reduce this, but remember that there is a manual
  # process for rotating the trust anchor!
  duration: 8760h0m0s
  renewBefore: 7320h0m0s
  privateKey:
    rotationPolicy: Always
    algorithm: ECDSA
  YAML

  depends_on = [kubectl_manifest.linkerd_issuer]
}

resource "kubectl_manifest" "linkerd_cluster_issuer" {
  yaml_body = <<-YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  # This is the name of the Issuer resource; it's the way
  # Certificate resources can find this issuer.
  name: linkerd-identity-issuer
  namespace: cert-manager
spec:
  ca:
    secretName: linkerd-trust-anchor
  YAML

  depends_on = [kubectl_manifest.linkerd_certificate]
}

resource "kubectl_manifest" "linkerd_identity_issuer" {
  yaml_body = <<-YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  # This is the name of the Certificate resource, but the Secret
  # we save the certificate into can be different.
  name: linkerd-identity-issuer
  namespace: ${var.namespace}
spec:
  # This tells cert-manager which issuer to use for this Certificate:
  # in this case, the ClusterIssuer named linkerd-identity-issuer.
  issuerRef:
    name: linkerd-identity-issuer
    kind: ClusterIssuer

  # The issued certificate will be saved in this Secret.
  secretName: linkerd-identity-issuer

  # These are details about the certificate to be issued: check
  # out the cert-manager docs for more, but realize that setting
  # the private key's rotationPolicy to Always is _very_ important,
  # and that for Linkerd you _must_ set isCA to true!
  isCA: true
  commonName: identity.linkerd.cluster.local
  # This is a two-day duration, rotating slightly over a day before
  # expiry. Feel free to set this as you like.
  duration: 48h0m0s
  renewBefore: 25h0m0s
  privateKey:
    rotationPolicy: Always
    algorithm: ECDSA
  YAML

  depends_on = [kubectl_manifest.linkerd_role_binding]
}

data "kubernetes_secret" "linkerd_trust_anchor" {
  metadata {
    name      = "linkerd-trust-anchor"
    namespace = "cert-manager"
  }
}

# Secret linkerd-previous-anchor baseado no linkerd-trust-anchor
# Este secret é necessário para rotação de certificados do Linkerd
resource "kubectl_manifest" "linkerd_previous_anchor" {
  yaml_body = <<-YAML
apiVersion: v1
kind: Secret
metadata:
  name: linkerd-previous-anchor
  namespace: cert-manager
type: kubernetes.io/tls
data:
  tls.crt: ${base64encode(data.kubernetes_secret.linkerd_trust_anchor.data["tls.crt"])}
  tls.key: ${base64encode(data.kubernetes_secret.linkerd_trust_anchor.data["tls.key"])}
  ca.crt: ${base64encode(data.kubernetes_secret.linkerd_trust_anchor.data["ca.crt"])}
  YAML

  depends_on = [data.kubernetes_secret.linkerd_trust_anchor]
}

resource "kubectl_manifest" "linkerd_bundle" {
  yaml_body = <<-YAML
apiVersion: trust.cert-manager.io/v1alpha1
kind: Bundle
metadata:
  # This is the name of the Bundle and _also_ the name of the
  # ConfigMap in which we'll write the trust bundle.
  name: linkerd-identity-trust-roots
spec:
  # This tells trust-manager where to find the public keys to copy into
  # the trust bundle.
  sources:
    # This is the Secret that cert-manager will update when it rotates
    # the trust anchor.
    - secret:
        name: "linkerd-trust-anchor"
        key: "tls.crt"

    # This is the Secret that we will use to hold the previous trust
    # anchor; we'll manually update this Secret after we're finished
    # restarting things.
    - secret:
        name: "linkerd-previous-anchor"
        key: "tls.crt"

  # This tells trust-manager the key to use when writing the trust
  # bundle into the ConfigMap. The target stanza doesn't have a way
  # to specify the name of the namespace, but thankfully Linkerd puts
  # a unique label on the control plane's namespace.
  target:
    configMap:
      key: "ca-bundle.crt"
    namespaceSelector:
      matchLabels:
        linkerd.io/is-control-plane: "true"
  YAML

  depends_on = [kubectl_manifest.linkerd_previous_anchor]
}