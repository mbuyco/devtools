#!/usr/bin/env bash

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

eval "$(ssh-agent -s)" \
  && ssh-add "$HOME/.ssh/id_ed25519" \
  && docker-compose -f "$DIR/docker/docker-compose.yml" build \
  && docker-compose -f "$DIR/docker/docker-compose.yml" run devtools_container
