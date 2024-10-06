#!/bin/bash

(
  SERVER_NAME="user_db"

  ./05_BASE_generate_certs.sh --server_name="$SERVER_NAME"
)