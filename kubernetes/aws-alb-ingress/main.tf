resource "kubernetes_namespace" "aws-alb-ingress" {
  metadata {
    name = var.namespace
    labels = var.namespace_labels
    annotations = var.namespace_annotations
  }
}

resource "kubectl_manifest" "linkerd_service_account" {
  yaml_body = <<-YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: alb-ingress-controller
  namespace: ${var.namespace}
  annotations:
    eks.amazonaws.com/role-arn: ${module.aws-load-balancer-controller-role.role_arn}
  YAML
}

resource "helm_release" "aws-alb-ingress" {
  name             = "aws-load-balancer-controller"
  repository       = "https://aws.github.io/eks-charts"
  chart            = "aws-load-balancer-controller"
  version          = var.aws_alb_ingress_version
  create_namespace = true
  namespace        = var.namespace
  cleanup_on_fail  = true

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "alb-ingress-controller"
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }
  
}