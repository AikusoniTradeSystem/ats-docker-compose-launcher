#!/bin/bash

(
  CERT_PATH="./credentials/certs"

  ROOT_PRIVATE_KEY_PATH="${CERT_PATH}/pk/root"
  CA_CERT_PATH="${CERT_PATH}/ca/${SERVER_NAME}"

  openssl genrsa -out "${ROOT_PRIVATE_KEY_PATH}/rootCA.key" 4096
)