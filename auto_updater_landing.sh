#!/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/projects/landing"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"


git_has_updates() {
    local repo_path="$1"
    local branch="${2:-main}"

    cd "$repo_path" || return 2

    local remote_hash=$(git ls-remote origin -h "refs/heads/$branch" | awk '{print $1}')
    local local_hash=$(git rev-parse HEAD)

    if [ "$local_hash" != "$remote_hash" ]; then
        return 0   # updates available
    else
        return 1   # up to date
    fi
}


set -e

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
