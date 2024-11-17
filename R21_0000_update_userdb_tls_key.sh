#!/bin/bash

# ==============================================
# Script Name:	Update User Database SSL Key
# Description:	This script updates the SSL key for the user database.
# ==============================================

(
  source CMN_load_env.sh
  source CMN_load_function.sh

  try docker exec -i "${USER_DB_CONTAINER_NAME}" mkdir -p "${USER_DB_CLIENT_CRYPTO_PATH}"
)
