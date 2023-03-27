# terraform-minikube-development

This terraform module is meant to hook directly into your local minikube setup and provision base Kubernetes integrations and ArgoCD in order to mimic the kubernetes setup in AWS or other cloud providers.

## Pre-Requisites / Local Environment Setup
- Kubernetes Environment
  - Minikube _(recommended)_
  - Docker Desktop
- `kubectl` CLI
- `argocd` CLI
- `helm` CLI
- `terraform` and `terragrunt` CLI

It's recommended for **BOTH** Mac and Linux users to install Homebrew (https://brew.sh)

## Minikube Setup Instructions
https://minikube.sigs.k8s.io/docs/start/

**NOTE:** We are currently using Kubernetes 1.21. Minikube, by default, spawns using Kubernetes 1.23 so you need to manually specify the version we're using in AWS.
**TODO:** _Virtualisation recommendations + hardware resource allocations_

> After minikube installation _(via Homebrew recommended)_: 
```bash
minikube start --kubernetes-version=1.21.9
minikube addons enable ingress
minikube addons enable registry
```    

### Cluster Monitoring Tools:
* [Lens](https://k8slens.dev/)
* [Octant](https://https://octant.dev/)
* [K9s](https://k9scli.io/)

### Other Minikube Tips and Tricks
- [Using local image registry (versus Gitlab)](https://minikube.sigs.k8s.io/docs/handbook/pushing/#4-pushing-to-an-in-cluster-using-registry-addon)
- [Loading images into minikube countainer runtime](https://minikube.sigs.k8s.io/docs/handbook/pushing/#7-loading-directly-to-in-cluster-container-runtime)
- [Cache images in minikube](https://minikube.sigs.k8s.io/docs/handbook/pushing/#4-pushing-to-an-in-cluster-using-registry-addon)

## Docker Desktop Setup Instructions
TBC...
<!-- ### Docker Desktop Differences and Separate Configurations Required _(Legacy)_
The difference between `docker-desktop` and `minikube` so far is:
1. kube-registry, minikube has addons docker registry
2. ingress, minikube has addons ingress

### Create the image registry
If you use Docker desktop, you need to install a Docker Registry where to pull images from. Start by creating the volume: see [kube-registry pv](99_kube-registry/README.md)   -->

## `kubectl` Setup Instructions
- After installing `kubectl`, please ensure `KUBECONFIG` is set, typically pointing to `$HOME/.kube/config` and verify that the current context is set to `minikube` or `docker-desktop` depending on your previous setup choices.
- In order for your local machine's minikube's ARGOCD to access the required gitlab repositories, you need to create and add an SSH key to your gitlab. Currently this is hard-coded to be at `~/.ssh/argo-minikube`. This specialised key needs to be created for now.

> TODO: Update some of these hard-coded items to be more flexible and/or targeted, such as the argo-minikube SSH key.

## Terraform/Terragrunt Setup Instructions
You can use this terraform module to provision all the necessary components on your local machine. Terraform state is not as critical for your local machine as you can always run `minikube delete` and respawn minikube/k8s and re-run terraform from scratch.

### Create Personal Access Token for Gitlab Repo Access
1. A personal access token with read_repository, read_registry, read_package_registry is recommended. Can be created here: https://gitlab.int.hextech.io/-/profile/personal_access_tokens
2. Copy `.env.yaml.example` to `.env.yaml` and add your gitlab username and the personal access token to the appropriate variables:
```yaml
GITLAB_API_V4_URL: "https://gitlab.int.hextech.io/api/v4/"
GITLAB_USERNAME: "{your gitlab username}"
GITLAB_TOKEN: "{personal access token here}"
```

### Terragrunt init and apply

1. `terragrunt init`
2. `terragrunt plan` _(optional)_
3. `terragrunt apply`
4. `terragrunt destroy`

### What does terraform do?
1. Creates namespaces: `["cert-manager", "ingress", "external-secrets", "kafka", "redis", "postgres"]`
2. Creates repository secrets for access to gitlab
3. Creates a local postgres instance _(TODO)_
4. Creates self-signed Certificate Authority*
5. Deploy ArgoCD with required ApplicationSets for _"Infrastructure"_ and _"Metazen"_ _(TODO: Customise to allow for other Minikube paradigms in the future)_

* *The self-signed certificate authority is a way to test/manage HTTPS/TLS ingress/deployments within a local development environment; a script (set up for both Linux and Mac) will create a TLS cert and attempt to add it to your master certs on your local machine. Administrator access will be required.

### Troubleshooting Tips
_Before you panic:_

- read the SYNC error
- read POD logs
- try argocd SYNC with PRUNE + REPLACE to force resources to be re-created
- try argocd DELETE a specific app and SYNC to force the whole app to be re-created
- delete POD to force it to be re-created (kubectl delete pod ...)

## Doc generation

Code formatting and documentation for variables and outputs is generated using [pre-commit-terraform hooks](https://github.com/antonbabenko/pre-commit-terraform) which uses [terraform-docs](https://github.com/segmentio/terraform-docs).

Follow [these instructions](https://github.com/antonbabenko/pre-commit-terraform#how-to-install) to install pre-commit locally.

And install `terraform-docs` with `go get github.com/segmentio/terraform-docs` or `brew install terraform-docs`.

## Contributing

Report issues/questions/feature requests on in the [issues](https://gitlab.int.hextech.io/technology/utils/developers/terraform-minikube-hextrust-development/issues/new) section.

## Authors

Created by [Aaron Baideme](https://gitlab.int.hextech.io/aaron.baideme) - aaron.baideme@hextrust.com

Supported by Marcus Cheng - marcus.cheng@hextrust.com

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.11 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.2 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | ~> 3.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | 2.9.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | 2.11.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.cluster](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret.local_selfsigned_ca](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [null_resource.local_security_trust_selfsigned_ca](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.local](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [tls_self_signed_cert.local](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_manifest"></a> [custom\_manifest](#input\_custom\_manifest) | Custom ArgoCD Manifest to provision local components; By default this is configured to do Infra Minikube support items and Metazen Development | `string` | `"redis-ha:\n  enabled: false\n\ncontroller:\n  enableStatefulSet: true # require in HA mode\n\nserver:\n  replicas: 1\n  env:\n    - name: ARGOCD_API_SERVER_REPLICAS\n      value: '1'\n  ingress:\n    enabled: true\n    ingressClassName: nginx\n    # Do not define tls certifcation, use default from nginx ingress\n    hosts:\n      - argocd.localhost\n  extraArgs:\n    # Handle TLS on ingress level \n    - --insecure\n\nrepoServer:\n  replicas: 1\n\nconfigs:\n  knownHosts:\n    data:\n      ssh_known_hosts: \"\"\n"` | no |
| <a name="input_root_domain_name"></a> [root\_domain\_name](#input\_root\_domain\_name) | Local Domain name that can route to minikube ip | `string` | `"localhost"` | no |
| <a name="input_tfenv"></a> [tfenv](#input\_tfenv) | n/a | `string` | `"minikube"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

