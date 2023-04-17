variable "custom_manifest" {
  type        = string
  description = "Custom ArgoCD Manifest to provision local components; By default this is configured to do Infra Minikube support items and Metazen Development"
  default     = <<EOT
redis-ha:
  enabled: false

controller:
  enableStatefulSet: true # require in HA mode

server:
  replicas: 1
  env:
    - name: ARGOCD_API_SERVER_REPLICAS
      value: '1'
  ingress:
    enabled: true
    ingressClassName: nginx
    # Do not define tls certifcation, use default from nginx ingress
    hosts:
      - argocd.localhost
  extraArgs:
    # Handle TLS on ingress level 
    - --insecure

repoServer:
  replicas: 1

configs:
  knownHosts:
    data:
      ssh_known_hosts: ""
EOT
}

variable "root_domain_name" {
  type        = string
  description = "Local Domain name that can route to minikube ip"
  default     = "localhost"
}
variable "repository_secrets" {
  type    = list(any)
  default = []
}
variable "credential_templates" {
  type    = list(any)
  default = []
}
variable "registry_secrets" {
  type    = list(any)
  default = []
}

variable "generate_plugin_repository_secret" {
  default = false
}
variable "additionalProjects" {
  type    = list(any)
  default = []
}
variable "chart_version" {
  default = "5.29.1"
}

