resource "kubernetes_namespace" "cluster" {
  for_each = toset(local.namespaces)

  metadata {
    labels = {
      name              = each.key
      "Terraform"       = true
      "eks/name"        = local.name_prefix
      "eks/environment" = var.tfenv
    }
    name = each.key
  }
}

locals {
  namespaces  = ["cert-manager", "ingress", "external-secrets", "kafka", "argocd", "grafana-stack", ]
  name_prefix = "minikube"
}
variable "tfenv" {
  type    = string
  default = "minikube"
}