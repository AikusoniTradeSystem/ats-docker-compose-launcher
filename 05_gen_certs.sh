#!/bin/sh

(
  mkdir -p ./certs/vault

  openssl genrsa -out ./certs/vault/server.key 4096
  openssl req -new -key ./certs/vault/server.key -out ./certs/vault/server.csr
  openssl x509 -req -in ./certs/vault/server.csr -signkey ./certs/vault/server.key -out ./certs/vault/server.crt -days 365

  openssl genrsa -out ./certs/vault/client.key 4096
  openssl req -new -key ./certs/vault/client.key -out ./certs/vault/client.csr -subj "/CN=vault_client"
  openssl x509 -req -in ./certs/vault/client.csr -CA ./certs/vault/server.crt -CAkey ./certs/vault/server.key -out ./certs/vault/client.crt -days 365 -CAcreateserial

  cp ./certs/vault/server.crt ./certs/vault/ca.crt
)