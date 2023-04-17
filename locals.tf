locals {
  ## TODO: Secret assumed secrets_store is ssm
  helmRepositoryYaml = {
    apiVersion = ""
    generated  = "0001-01-01T00:00:00Z"
    repositories = [
      for secret in var.repository_secrets :
      {
        caFile                   = ""
        certFile                 = ""
        insecure_skip_tls_verify = false
        keyFile                  = ""
        pass_credentials_all     = false
        name                     = secret.name
        url                      = secret.url
        username                 = secret.username
        password                 = secret.password
      }
      if secret.type == "helm"
    ]
  }


}
