#!/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR"
COMPOSE_FILE="$SCRIPT_DIR/../../docker-compose.yml"
COMPOSE_FILE=$(realpath "$COMPOSE_FILE")

set -e

# Добавляем исключение для Git (чтобы избежать ошибки dubious ownership)
git config --global --add safe.directory "$SOURCE_DIR"

echo -e "${YELLOW}Updating code from git...${NC}"
git -C "$SOURCE_DIR" pull

echo -e "${YELLOW}Rebuilding image...${NC}"
docker-compose -f "$COMPOSE_FILE" build --no-cache landing

echo -e "${YELLOW}Stopping and removing old landing container...${NC}"
docker-compose -f "$COMPOSE_FILE" stop -t 3 landing || true
docker-compose -f "$COMPOSE_FILE" rm -f landing || true

echo -e "${YELLOW}Launching updated container...${NC}"
docker-compose -f "$COMPOSE_FILE" up -d landing

echo -e "${GREEN}Success!${NC}"
docker-compose -f "$COMPOSE_FILE" ps landing
