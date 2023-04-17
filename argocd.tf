resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = false
  version          = var.chart_version

  depends_on = [
    resource.null_resource.local_security_trust_selfsigned_ca,
    resource.kubernetes_namespace.cluster
  ]

  ## Default values.yaml + configuration
  ## https://github.com/argoproj/argo-helm/blob/master/charts/argo-cd/values.yaml
  values = var.custom_manifest != null ? [var.custom_manifest] : [<<EOT
server:
  env:
    - name: ARGOCD_API_SERVER_REPLICAS
      value: '1'
  ingress:
    enabled: true
    ingressClassName: nginx
    hosts:
      - argocd.${var.root_domain_name}
  extraArgs:
    - --insecure
EOT
  ]
}

resource "kubectl_manifest" "applicationsets" {
  for_each = { for applicationSet in try(var.custom_manifest.application_sets, []) : regex("[A-Za-z0-9-]+", applicationSet.filepath) => applicationSet }
  depends_on = [
    helm_release.argocd
  ]

  yaml_body = templatefile(
    each.value.filepath,
    each.value.envvars
  )
}
