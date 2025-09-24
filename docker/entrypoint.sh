#!/usr/bin/env bash
set -euo pipefail

# entrypoint.sh - runtime helper for dev container
# Behavior:
#  - If NVIM_REPO is empty -> skip cloning
#  - If NVIM_REPO set:
#      - if ~/.config/nvim exists and NVIM_FORCE!=1 => prompt (if interactive) or abort (non-interactive)
#      - if NVIM_FORCE=1 => remove and clone
# After handling config, drop into provided command (default zsh)

NVIM_REPO=${NVIM_REPO:-}
NVIM_FORCE=${NVIM_FORCE:-0}
NVIM_CONFIG_DIR=${NVIM_CONFIG_DIR:-"$HOME/.config/nvim"}

prompt_confirm() {
  # returns 0 for yes, 1 for no
  local prompt default reply
  prompt="$1"
  default="$2" # "y" or "n"
  if [ -t 0 ]; then
    if [ "$default" = "y" ]; then
      read -r -p "$prompt [Y/n]: " reply
      reply=${reply:-y}
    else
      read -r -p "$prompt [y/N]: " reply
      reply=${reply:-n}
    fi
    case "${reply,,}" in
      y|yes) return 0 ;;
      *) return 1 ;;
    esac
  else
    # non-interactive: default to "no"
    return 1
  fi
}

echo "Starting dev container as $(id -un)."

# Ensure $HOME exists and is owned by user
echo "$HOME"

exit 1
# mkdir -p "$HOME"
# chown -R "$(id -u):$(id -g)" "$HOME" || true

if [ -n "$NVIM_REPO" ]; then
  echo "NVIM_REPO is set: $NVIM_REPO"
  if [ -d "$NVIM_CONFIG_DIR" ]; then
    echo "Detected existing Neovim config at $NVIM_CONFIG_DIR"
    if [ "$NVIM_FORCE" = "1" ]; then
      echo "NVIM_FORCE=1, removing existing config..."
      rm -rf "$NVIM_CONFIG_DIR"
    else
      if prompt_confirm "Delete existing $NVIM_CONFIG_DIR and replace with $NVIM_REPO?" "n"; then
        echo "Removing $NVIM_CONFIG_DIR..."
        rm -rf "$NVIM_CONFIG_DIR"
      else
        echo "Installation aborted by user."
        # continue to shell rather than exiting: keep container usable
        exec "$@"
      fi
    fi
  fi

  # Clone repo
  echo "Cloning $NVIM_REPO -> $NVIM_CONFIG_DIR"
  git clone --depth=1 "$NVIM_REPO" "$NVIM_CONFIG_DIR" || {
    echo "Git clone failed. Aborting clone step."
  }

  # Ensure ownership
  chown -R "$(id -u):$(id -g)" "$NVIM_CONFIG_DIR" || true

  echo "Neovim config installed at $NVIM_CONFIG_DIR."
fi

# Launch final command (default zsh)
if [ $# -gt 0 ]; then
  exec "$@"
else
  exec zsh
fi
