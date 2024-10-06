#!/bin/bash

(
  SERVER_NAME="vault"

  ./05_BASE_generate_certs.sh --server_name="$SERVER_NAME"
)