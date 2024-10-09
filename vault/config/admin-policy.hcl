# System capabilities: Seal/Unseal, List and View Vault status
path "sys/seal" {
  capabilities = ["update"]
}

path "sys/unseal" {
  capabilities = ["update"]
}

path "sys/health" {
  capabilities = ["read"]
}

path "sys/capabilities-self" {
  capabilities = ["read"]
}

# Enable/disable auth methods
path "auth/*" {
  capabilities = ["create", "update", "read", "delete", "list"]
}

# List and manage policies
path "sys/policies/acl" {
  capabilities = ["create", "update", "read", "delete", "list"]
}

# Manage tokens and leases
path "auth/token/*" {
  capabilities = ["create", "update", "read", "delete", "list"]
}

# Manage secret engines
path "sys/mounts/*" {
  capabilities = ["create", "update", "read", "delete", "list"]
}

# Read/write secrets for all paths (optionally restrict to specific paths)
path "secret/data/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
