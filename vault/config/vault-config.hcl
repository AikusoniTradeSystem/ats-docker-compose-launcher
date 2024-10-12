storage "file" {
  path = "/vault/data"
}

listener "tcp" {
  address     = "0.0.0.0:8200"
  tls_disable = 0
  tls_cert_file = "/etc/ssl/certs/server.crt"
  tls_key_file  = "/etc/ssl/private/server.key"
}

audit "file" {
  file_path = "/vault/logs/vault_audit.log"
  log_raw   = true
}

path "pki/issue/*" {
    capabilities = ["create", "read"]
}

path "pki/cert/*" {
    capabilities = ["read"]
}

path "pki/revoke/*" {
    capabilities = []
}

ui = true