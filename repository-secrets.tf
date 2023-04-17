resource "kubernetes_secret" "argocd_application_repository_secrets" {
  for_each = {
    for repository_secret in var.repository_secrets : repository_secret.name => repository_secret
  }

  metadata {
    name      = "repository-${each.value.name}"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    name     = each.value.name
    url      = each.value.url
    type     = each.value.type
    username = each.value.username
    password = each.value.password
  }
}

resource "kubernetes_secret" "argocd_helm_envsubst_plugin_repositories" {
  count = coalesce(var.generate_plugin_repository_secret, false) ? 1 : 0

  metadata {
    name      = "argocd-helm-envsubst-plugin-repositories"
    namespace = "argocd"
  }

  data = {
    "repositories.yaml" = yamlencode(local.helmRepositoryYaml)
  }
}
