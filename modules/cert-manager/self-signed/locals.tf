locals {
  helm_values = [{
    cert-manager = {
      tlsCrt = base64encode(tls_self_signed_cert.root.cert_pem)
      tlsKey = base64encode(tls_private_key.root.private_key_pem)
      clusterIssuers = {
        letsencrypt = {
          enabled = false
        }
      }
    }
  }]
}
