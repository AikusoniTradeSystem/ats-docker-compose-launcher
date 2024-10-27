#!/bin/bash

STORAGE_DIR="./storage"
CREDENTIALS_DIR="./credentials"
BACKUP_DIR="./backup_$(date +%Y%m%d%H%M%S)"

mkdir -p "$BACKUP_DIR"

cleanup_storage() {
  echo "Cleaning up storage directory: $STORAGE_DIR"
  find "$STORAGE_DIR" -type f ! -name ".gitkeep" -exec rm -v {} \;
}

cleanup_credentials() {
  echo "Cleaning up credentials directory: $CREDENTIALS_DIR"
  find "$CREDENTIALS_DIR" -type f ! -name ".gitkeep" -exec rm -v {} \;
}

cleanup_storage
cleanup_credentials

echo "Cleanup completed. All files except .gitkeep have been removed."