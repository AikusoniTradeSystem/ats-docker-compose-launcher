path "sys/" {
  capabilities = ["read", "list"]
}

path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "database/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "auth/token/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
