#!/bin/bash

# Start PostgreSQL in the background with SSL options
docker-entrypoint.sh postgres -c ssl=on \
                               -c ssl_cert_file=/etc/ssl/certs/server.crt \
                               -c ssl_key_file=/etc/ssl/certs/server.key \
                               -c ssl_ca_file=/etc/ssl/certs/ca.crt &

# Set timeout (in seconds)
TIMEOUT=30
ELAPSED=0
INTERVAL=1

# Wait for PostgreSQL to become available
until pg_isready -U "${POSTGRES_USER}"; do
  if [ $ELAPSED -ge $TIMEOUT ]; then
    echo "PostgreSQL did not start in time. Exiting."
    exit 1
  fi
  echo "Waiting for PostgreSQL to become available..."
  sleep $INTERVAL
  ELAPSED=$((ELAPSED + INTERVAL))
done

echo "PostgreSQL is up and running!"

# Execute all SQL scripts in /docker-entrypoint-initdb.d in order
for sql_file in $(ls /docker-entrypoint-initdb.d/*.sql | sort); do
  if [ -e "$sql_file" ]; then
    echo "Executing script: $sql_file"
    psql -U "${POSTGRES_USER}" -d "${POSTGRES_DB}" -f "$sql_file"
  fi
done

# Wait for PostgreSQL to shut down gracefully
wait