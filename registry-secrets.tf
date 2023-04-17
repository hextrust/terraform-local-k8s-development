resource "kubernetes_secret" "regcred" {
  for_each = { for regcred in coalesce(var.registry_secrets, []) : "${regcred.name}-argocd" => regcred }

  metadata {
    name      = "registry-${each.value.name}"
    namespace = "argocd"
  }

  data = {
    ".dockerconfigjson" = sensitive(jsonencode({
      auths = {
        (each.value.url) = {
          "username" = each.value.username
          "password" = each.value.password
          "email"    = each.value.email
          "auth"     = base64encode("${each.value.username}:${each.value.password}")
        }
      }
    }))
  }

  type = "kubernetes.io/dockerconfigjson"
}
