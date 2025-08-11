# DevOps Group - Permissões administrativas gerais
resource "kubernetes_cluster_role" "devops_role" {
  count = var.cluster_name != "" ? 1 : 0
  metadata {
    name = "devops-cluster-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "configmaps", "events", "namespaces", "deployments", "replicasets", "daemonsets", "statefulsets"]
    verbs      = ["*"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch", "describe"]
  }

  # Permissões de leitura em recursos de rede
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["*"]
  }

  #Permissões para Persistent Volumes e Persistent Volume Claims
  rule {
    api_groups = [""]
    resources  = ["persistentvolumes", "persistentvolumeclaims"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["*"]
  }

  #Permissões para Helm (releases)
  rule {
    api_groups = ["helm.cattle.io"]
    resources  = ["helmcharts", "helmchartconfigs"]
    verbs      = ["*"]
  }

  # Permissões para logs
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }

  # Permissões para port-forward (debug)
  rule {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["*"]
  }

  # Permissões de leitura em métricas
  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["external-secrets.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "devops_binding" {
  count = var.cluster_name != "" ? 1 : 0
  metadata {
    name = "devops-cluster-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.devops_role[0].metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "devops-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

# DevOps N3 Group - Permissões administrativas completas (incluindo RBAC)
resource "kubernetes_cluster_role" "devops_n3_role" {
  count = var.cluster_name != "" ? 1 : 0
  metadata {
    name = "devops-n3-cluster-role"
  }

  # Permissão total para RBAC (roles, rolebindings, clusterroles, clusterrolebindings, serviceaccounts)
  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs      = ["*"]
  }

  # Permissão total para serviceaccounts (necessário para RBAC avançado)
  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["*"]
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "configmaps", "events", "namespaces", "deployments", "replicasets", "daemonsets", "statefulsets"]
    verbs      = ["*"]
  }

  rule {
    api_groups = [""]
    resources  = ["nodes"]
    verbs      = ["get", "list", "watch", "describe"]
  }

  # Permissões de leitura em recursos de rede
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["*"]
  }

  #Permissões para Persistent Volumes e Persistent Volume Claims
  rule {
    api_groups = [""]
    resources  = ["persistentvolumes", "persistentvolumeclaims"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
    verbs      = ["*"]
  }

  #Permissões para Helm (releases)
  rule {
    api_groups = ["helm.cattle.io"]
    resources  = ["helmcharts", "helmchartconfigs"]
    verbs      = ["*"]
  }

  # Permissões para logs
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }

  # Permissões para port-forward (debug)
  rule {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["*"]
  }

  # Permissões de leitura em métricas
  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
    verbs      = ["get", "list"]
  }

  rule {
    api_groups = ["external-secrets.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "devops_n3_binding" {
  count = var.cluster_name != "" ? 1 : 0
  metadata {
    name = "devops-n3-cluster-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.devops_n3_role[0].metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "devops-n3-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

# Dev Group - Permissões limitadas para desenvolvimento
resource "kubernetes_cluster_role" "dev_role" {
  count = var.cluster_name != "" ? 1 : 0
  metadata {
    name = "dev-cluster-role"
  }

  # Permissões de leitura em recursos principais
  rule {
    api_groups = [""]
    resources  = ["pods", "services", "endpoints", "events", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }

  # Permissões de leitura em configmaps (limitadas)
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list", "watch"]
  }

  # Permissões de leitura em deployments e replicasets
  rule {
    api_groups = ["apps"]
    resources  = ["deployments", "replicasets", "daemonsets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  # Permissão para reiniciar deployments (patch)
  rule {
    api_groups = ["apps"]
    resources  = ["deployments"]
    verbs      = ["patch"]
  }

  # Permissão para deletar pods
  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["delete"]
  }

  # Permissões de leitura em recursos de rede
  rule {
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  # Permissões para logs
  rule {
    api_groups = [""]
    resources  = ["pods/log"]
    verbs      = ["get", "list", "watch"]
  }

  # Permissões de leitura em métricas
  rule {
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
    verbs      = ["get", "list"]
  }

  # Permissões para port-forward (debug)
  rule {
    api_groups = [""]
    resources  = ["pods/portforward"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["external-secrets.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["argoproj.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "dev_binding" {
  count = var.cluster_name != "" ? 1 : 0
  metadata {
    name = "dev-cluster-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.dev_role[0].metadata[0].name
  }

  subject {
    kind      = "Group"
    name      = "dev-group"
    api_group = "rbac.authorization.k8s.io"
  }
}

output "rbac_groups" {
  description = "Grupos RBAC configurados no cluster"
  value = {
    devops_group    = "devops-group"
    devops_n3_group = "devops-n3-group"
    dev_group       = "dev-group"
  }
}

output "cluster_roles" {
  description = "ClusterRoles criados"
  value = {
    devops_role    = try(kubernetes_cluster_role.devops_role[0].metadata[0].name, "")
    devops_n3_role = try(kubernetes_cluster_role.devops_n3_role[0].metadata[0].name, "")
    dev_role       = try(kubernetes_cluster_role.dev_role[0].metadata[0].name, "")
  }
}
