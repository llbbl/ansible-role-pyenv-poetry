#!/usr/bin/env bash
#
# Test script for ansible-role-pyenv-poetry
# Usage: ./test.sh [scenario]
# Scenarios: default, non-root-user, all

set -e

SCENARIO="${1:-default}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Ansible Role Test Script ===${NC}"
echo -e "${YELLOW}Scenario: ${SCENARIO}${NC}"
echo ""

# Ensure collections are installed
if [ ! -d "collections/ansible_collections/community/docker" ] || [ ! -d "collections/ansible_collections/ansible/posix" ]; then
    echo -e "${YELLOW}Installing Ansible collections...${NC}"
    mkdir -p collections
    poetry run ansible-galaxy collection install -r requirements.yml -p collections --force
fi

# Export environment variables for collections
export ANSIBLE_COLLECTIONS_PATH="$(pwd)/collections"
export PYTHONPATH="$(pwd)/collections:$PYTHONPATH"

# Run the test
if [ "$SCENARIO" = "all" ]; then
    echo -e "${GREEN}Running all scenarios...${NC}"
    poetry run molecule test --all
else
    echo -e "${GREEN}Running scenario: ${SCENARIO}${NC}"
    poetry run molecule test -s "$SCENARIO"
fi

echo ""
echo -e "${GREEN}✓ Tests completed successfully!${NC}"
