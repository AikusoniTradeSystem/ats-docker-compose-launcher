#!/bin/bash

# ==============================================
# Script Name:	Generate Root CA
# Description:	This script creates the root key and root CA certificate using the custom configuration file.
# ==============================================

(
  # Load configuration file
  source load_env.sh
  source load_function.sh

  # Create directories if they don't exist
  try mkdir -p "${ROOT_CA_CRYPTO_PATH}"
  try mkdir -p "${PUBLIC_CERT_PATH}"

  log i "Generating root key and root CA certificate using the custom configuration file..."
  log d "Root CA private key path: ${ROOT_CA_PRIVATE_KEY_PATH}"
  log d "Root CA certificate path: ${ROOT_CA_CERT_FILE_PATH}"
  log d "Root CA configuration file path: ${ROOT_CA_CNF_FILE_PATH}"

  # Generate root key
  try openssl genrsa -out "${ROOT_CA_PRIVATE_KEY_PATH}" 4096

  # Generate self-signed root CA certificate using the custom config file
  log i "Generating root CA certificate..."
  try openssl req -x509 -new -key "${ROOT_CA_PRIVATE_KEY_PATH}" \
    -sha256 -days 3650 \
    -out "${ROOT_CA_CERT_FILE_PATH}" \
    -config "${ROOT_CA_CNF_FILE_PATH}"

  # Copy the root CA certificate to the publish directory
  log i "Copying the root CA certificate to the publish directory... (${PUBLIC_CERT_PATH})"
  try cp "${ROOT_CA_CERT_FILE_PATH}" "${ROOT_CA_PUBLIC_CERT_PATH}"

  log s "${SHELL_TEXT_SUCCESS}Root key and root CA certificate have been generated successfully using the custom configuration file."
)

