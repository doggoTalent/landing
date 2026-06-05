#!/bin/bash

yellow='\033[1;33m'
green='\033[0;32m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/projects/landing"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

set -e

echo -e "${yellow}Updating sources...${NC}"
git -C "$SOURCE_DIR" pull

echo -e "${yellow}Stopping and removing old landing container...${NC}"
docker-compose -f "$COMPOSE_FILE" stop landing
docker-compose -f "$COMPOSE_FILE" rm -f landing

echo -e "${yellow}Rebuilding image...${NC}"
docker-compose -f "$COMPOSE_FILE" build --no-cache landing

echo -e "${yellow}Launching updated container...${NC}"
docker-compose -f "$COMPOSE_FILE" up -d landing

echo -e "${green}Success!${NC}"
docker-compose -f "$COMPOSE_FILE" ps landing
