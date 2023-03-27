# This example creates a self-signed certificate,
# and uses it to create an AWS IAM Server certificate.
#
# THIS IS NOT RECOMMENDED FOR PRODUCTION SERVICES.
# See the detailed documentation of each resource for further
# security considerations and other practical tradeoffs.

resource "tls_private_key" "local" {
  algorithm   = "RSA"
  rsa_bits    = 4096
  ecdsa_curve = "P224"
}

resource "tls_self_signed_cert" "local" {
  private_key_pem = tls_private_key.local.private_key_pem

  is_ca_certificate  = true
  set_subject_key_id = true

  # Certificate expires after 12 hours.
  validity_period_hours = 8760

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 3

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "data_encipherment",
    "key_agreement",
    "cert_signing",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["*.metazens.localhost", "hextech.localhost"]

  subject {
    common_name  = "*.hextech.localhost"
    organization = "HEXTECH LOCAL DEVELOPMENT"
    country      = "HK"
    locality     = "HK"
    province     = "HK"
  }
}

resource "kubernetes_secret" "local_selfsigned_ca" {
  depends_on = [resource.kubernetes_namespace.cluster]

  metadata {
    name      = "self-signed-ca"
    namespace = "cert-manager"
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = tls_self_signed_cert.local.cert_pem
    "tls.key" = tls_private_key.local.private_key_pem
  }
}

resource "null_resource" "local_security_trust_selfsigned_ca" {

  triggers = {
    shell_hash = sha256(file("${path.module}/scripts/trust-self-signed-cert-local-development.sh"))
  }
  provisioner "local-exec" {
    command     = "${path.module}/scripts/trust-self-signed-cert-local-development.sh"
    interpreter = ["bash"]
    working_dir = path.module
    environment = {
      SELF_SIGNED_CERT = base64encode(tls_self_signed_cert.local.cert_pem)
    }
  }
}

