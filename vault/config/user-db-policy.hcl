# Get credentials from the database secrets engine 'readonly' role.
path "database/creds/user-db" {
  capabilities = [ "read" ]
}