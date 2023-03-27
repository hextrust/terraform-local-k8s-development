locals {
  env    = yamldecode(file(".env.yaml.example"))
}

# Indicate where to source the terraform module from.
# The URL used here is a shorthand for
# "tfr://registry.terraform.io/terraform-aws-modules/vpc/aws?version=3.5.0".
# Note the extra `/` after the protocol is required for the shorthand
# notation.
terraform {
  source = "../../"
}

## Indicate the input values to use for the variables of the module.
##
## Currently there are no input variables required unless you plan to override ARGO's initial provisioning configuration. 
## See: https://github.com/hextrust/terraform-local-k8s-development/blob/main/README.md
inputs = {
  argocd = {
    application_sets = []
  }

  additionalProjects = [
    {
      name        = "local-infrastructure-base"
      description = "Standard Kubernetes Provisioning for Infrastructure"
      clusterResourceWhitelist = [{
        group = "*"
        kind = "*"
      }]
      destinations = [{
        name = "local"
        namespace = "*"
        server = "*"
      }]
      sourceRepos = [
        "https://github.com/hextrust/argocd-kubernetes-infrastructure.git"
      ]
    },
  ],
  repository_secrets = []
  credential_templates = []
  registry_secrets = []

  generate_plugin_repository_secret = false
}

## Kubernetes and Helm Providers should look for local kubeconfig and use minikube context by default
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "kubernetes" {
  config_path    = "${local.env.LOCAL_KUBECONFIG_PATH}"
  config_context = "${local.env.LOCAL_KUBECONFIG_CONTEXT}"
}

provider "helm" {
  kubernetes {
    config_path    = "${local.env.LOCAL_KUBECONFIG_PATH}"
    config_context = "${local.env.LOCAL_KUBECONFIG_CONTEXT}"
  }
}

EOF
}

## We try to manage state for local developers within their $HOME/.kube folder, /tmp as a fallback
remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    path      = "${get_env("HOME", "/tmp")}/.kube/local-k8s.tfstate"
  }
}

