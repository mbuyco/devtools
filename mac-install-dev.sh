#!/bin/bash

set -eu

echo "=== macOS Dev Environment Setup ==="

if ! command -v brew &> /dev/null; then
  echo "Homebrew not found. Installng..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH for Apple Silicon
  echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo "Homebrew already installed."
fi

echo "=== Installing packages with Homebrew ==="
brew update
brew install zsh neovim tmux git curl

if [ "$SHELL" != "/bin/zsh" ]; then
  echo "Changing default shell to zsh..."
  chsh -s /bin/zsh
fi

echo "=== Installing Oh My Zsh ==="
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no KEEPZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Zsh is already installed."
fi

echo "=== Installing Tmux Plugin Manager (TPM) ==="
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm $TPM_DIR
else
  echo "Tmux TPM is already installed."
fi

echo "=== Installing NVIM configuration ==="
NVIM_CONFIG_DIR="$HOME/.config/nvim"
NVIM_CONFIG_REPO_URL="git@github.com:mbuyco/nvim-config-lua.git"
SUCCESS_MESSAGE="Neovim configuration successfully installed at $NVIM_CONFIG_DIR."
if [ -d "$NVIM_CONFIG_DIR" ]; then
  read -p "Neovim config already exists at $NVIM_CONFIG_DIR. Delete and replace? (y/N): " confirm
  confirm=$(echo "$confirm" | tr '[:upper:]' '[:lower:]')
  if [[ "$confirm" == "y" || "$confirm" == "yes" ]]; then
    echo "Deleting existing config..."
    rm -rf "$NVIM_CONFIG_DIR"
    git clone "$NVIM_CONFIG_REPO_URL" "$NVIM_CONFIG_DIR"
    echo "$SUCCESS_MESSAGE"
  else
    echo "Installation aborted by user."
  fi
else
  echo "Cloning neovim config..."
  git clone "$NVIM_CONFIG_REPO_URL" "$NVIM_CONFIG_DIR"
  echo "$SUCCESS_MESSAGE"
fi

echo "=== Installing Dotfiles ==="
DOTFILES_REPO_URL="git@github.com:mbuyco/dotfiles.git"
DOTFILES_PATH="$HOME/dotfiles"
SUCCESS_MESSAGE="Dotfiles successfully installed at $DOTFILES_PATH."
if [ ! -d "$DOTFILES_PATH" ]; then
  echo "Cloning dotfiles..."
  git clone "$DOTFILES_REPO_URL" "$DOTFILES_PATH"
  echo "$SUCCESS_MESSAGE"
else
  echo "Dotfiles already exist, skipping installation..."
fi

echo "=== Installing ZSH config ==="
ZSH_CONFIG_SRC="$DOTFILES_PATH/zsh"
if [ -e "$HOME/.zsh_aliases" ]; then
  rm "$HOME/.zsh_aliases"
fi
if [ -e "$HOME/.zshrc" ]; then
  rm "$HOME/.zshrc"
fi
ln -s "$ZSH_CONFIG_SRC/.zsh_aliases" "$HOME/.zsh_aliases"
ln -s "$ZSH_CONFIG_SRC/.zshrc" "$HOME/.zshrc"

# Install zsh plugins
ZSH_AUTOSUGGESTIONS_PLUGIN_PATH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
ZSH_SYNTAX_HIGHLIGHTING_PLUGIN_PATH="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
if [ ! -d "$ZSH_AUTOSUGGESTIONS_PLUGIN_PATH" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_AUTOSUGGESTIONS_PLUGIN_PATH"
fi
if [ ! -d "$ZSH_SYNTAX_HIGHLIGHTING_PLUGIN_PATH" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_SYNTAX_HIGHLIGHTING_PLUGIN_PATH"
fi
echo "ZSH config installed successfully"

echo "=== Installing Tmux Configuration ==="
if [ -e "$HOME/.tmux.conf" ]; then
  rm "$HOME/.tmux.conf"
fi
ln -s "$DOTFILES_PATH/tmux/.tmux.conf" "$HOME/.tmux.conf"
echo "Tmux Configuration installed successfully"

echo "=== Installing OpenCode CLI Agent ==="
if ! command -v opencode &> /dev/null; then
  curl -fsSL https://opencode.ai/install | bash
  echo "OpenCode CLI Agent installed successfully"
else
  echo "OpenCode CLI Agent already installed"
fi

echo "=== Installation Complete ==="
echo "Next steps:"
echo "  - Restart your terminal to use zsh"
echo "  - Open nvim to configure Lazy.nvim"
echo "  - Start tmux and press prefix + I to install TPM plugins"
