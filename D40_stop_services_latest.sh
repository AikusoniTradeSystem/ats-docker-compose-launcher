#!/bin/bash

(
  source common.sh

  docker compose -f 40_docker-compose.latest.yml down -v
)
