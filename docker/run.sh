#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect host UID/GID and export as env vars
export USER_UID=$(id -u)
export USER_GID=$(id -g)

eval "$(ssh-agent -s)" \
  && ssh-add "$HOME/.ssh/id_ed25519" \
  && docker-compose -f "$DIR/docker/docker-compose.yml" build \
  && docker-compose -f "$DIR/docker/docker-compose.yml" run --remove-orphans --rm devtools_container
