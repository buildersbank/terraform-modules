variable "namespace" {
  description = "Namespace to install ArgoCD chart into"
  type        = string
  default     = "argocd"
}

variable "argocd_version" {
  description = "Version of ArgoCD chart to install"
  type        = string
  default     = "stable"
}

variable "argocd-cmd-params-cm" {
  description = "ArgoCD command parameters"
  type        = map(string)
  default     = {
    "server.insecure" = "true"
  }
}
