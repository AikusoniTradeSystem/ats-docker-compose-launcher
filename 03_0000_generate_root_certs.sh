#!/bin/bash

# Load configuration file
source load_env.sh

# Create directories if they don't exist
mkdir -p "${ROOT_PRIVATE_KEY_CRYPTO_PATH}"
mkdir -p "${ROOT_CA_CRYPTO_PATH}"

echo -e "${SHELL_TEXT_INFO}Generating root key and root CA certificate using the custom configuration file...${SHELL_TEXT_RESET}"
echo -e "Root key path: ${ROOT_PRIVATE_KEY_FILE_PATH}"
echo -e "Root CA certificate path: ${ROOT_CA_FILE_PATH}"
echo -e "Root CA configuration file path: ${ROOT_CA_CNF_FILE_PATH}"

# Generate root key
openssl genrsa -out "${ROOT_PRIVATE_KEY_FILE_PATH}" 4096

# Generate self-signed root CA certificate using the custom config file
openssl req -x509 -new -key "${ROOT_PRIVATE_KEY_FILE_PATH}" \
  -sha256 -days 3650 \
  -out "${ROOT_CA_FILE_PATH}" \
  -config "${ROOT_CA_CNF_FILE_PATH}"

echo -e "${SHELL_TEXT_SUCCESS}Root key and root CA certificate have been generated successfully using the custom configuration file.${SHELL_TEXT_RESET}"