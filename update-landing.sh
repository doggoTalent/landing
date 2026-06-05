#!/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR"
COMPOSE_FILE="$SCRIPT_DIR/../../docker-compose.yml"
COMPOSE_FILE=$(realpath "$COMPOSE_FILE")

git_has_updates() {
    local repo_path="$1"
    local branch="${2:-main}"

    cd "$repo_path" || return 2

    git fetch origin

    local remote_hash=$(git rev-parse "origin/$branch")
    local local_hash=$(git rev-parse HEAD)

    echo "[DEBUG] Local hash:  $local_hash"
    echo "[DEBUG] Remote hash: $remote_hash"

    if [ "$local_hash" != "$remote_hash" ]; then
        return 0   # updates available
    else
        return 1   # up to date
    fi
}

set -e

echo "[DEBUG] SOURCE_DIR = $SOURCE_DIR"
echo "[DEBUG] COMPOSE_FILE = $COMPOSE_FILE"

if git_has_updates "$SOURCE_DIR"; then
    echo -e "${GREEN}There are new updates${NC}"
    git -C "$SOURCE_DIR" pull

    echo -e "${YELLOW}Rebuilding image...${NC}"
    docker-compose -f "$COMPOSE_FILE" build --no-cache landing

    echo -e "${YELLOW}Stopping and removing old landing container...${NC}"
    docker-compose -f "$COMPOSE_FILE" stop -t 3 landing
    docker-compose -f "$COMPOSE_FILE" rm -f landing

    echo -e "${YELLOW}Launching updated container...${NC}"
    docker-compose -f "$COMPOSE_FILE" up -d landing

    echo -e "${GREEN}Success!${NC}"
else
    echo -e "${GREEN}Already up to date${NC}"
fi

docker-compose -f "$COMPOSE_FILE" ps landing
