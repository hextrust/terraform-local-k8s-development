resource "kubernetes_secret" "argocd_application_credential_template" {
  count = length(var.credential_templates)

  metadata {
    name      = "argocd-repo-creds-${var.credential_templates[count.index].name}"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    url      = var.credential_templates[count.index].url
    username = var.credential_templates[count.index].username
    password = var.credential_templates[count.index].password
  }
}
