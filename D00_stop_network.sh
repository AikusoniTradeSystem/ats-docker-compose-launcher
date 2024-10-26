#!/bin/bash
(
  source common.sh

  docker compose -f 00_docker-compose.network.yml down -v
)
