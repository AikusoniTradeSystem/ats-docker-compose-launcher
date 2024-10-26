#!/bin/bash

(
  source common.sh

  docker compose -f 10_docker-compose.db.yml down -v
)
