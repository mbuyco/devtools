# devtools

My Personal Development Tooling

## Overview

This project provides a lightweight, containerized development environment using Docker. Additionally, there is a script for setting up a similar environment on macOS systems.

The Docker setup creates an Ubuntu-based container with essential development tools, while the macOS script installs Homebrew, Zsh, Neovim, Tmux, and clones personal dotfiles and configurations.

## Installation

### Docker Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/mbuyco/devtools.git
   cd devtools
   ```

2. Copy the environment example file:
   ```bash
   cp docker/.env.example docker/.env
   ```

3. Edit `docker/.env` and fill in the required variables:
    - `IMAGE_AUTHOR`: Your name or identifier
    - `NVIM_REPO`: URL to your Neovim configuration repository
    - `DOTFILES_REPO`: URL to your dotfiles repository (see https://github.com/mbuyco/dotfiles for reference)
    - `WORKSPACE_PATH`: (Optional) Local path to mount as workspace in the container (defaults to /tmp)

4. Ensure your SSH key is available (the script uses `~/.ssh/id_ed25519`).

5. Run the setup script:
   ```bash
   ./run.sh
   ```

This will build the Docker image and start the container with your development environment.

### macOS Local Setup

Run the macOS installation script (ensure SSH keys are set up for GitHub cloning):
```bash
./mac-install-dev.sh
```

This script will:
- Install Homebrew (if not present)
- Install Zsh, Neovim, Tmux, Git, and Curl
- Set Zsh as the default shell
- Install Oh My Zsh and plugins (zsh-autosuggestions, zsh-syntax-highlighting)
- Install Tmux Plugin Manager (TPM)
- Clone Neovim configuration from `git@github.com:mbuyco/nvim-config-lua.git`
- Clone dotfiles from `git@github.com:mbuyco/dotfiles.git`
- Install OpenCode CLI Agent

After installation, restart your terminal and follow the next steps displayed by the script.

## Uninstallation

### Docker Setup

To remove the Docker container and image:
```bash
docker-compose -f docker/docker-compose.yml down --rmi all
```

Remove the cloned repositories and configurations as needed.

### macOS Local Setup

To uninstall the tools installed by the script:
- Remove Homebrew: Follow Homebrew's uninstallation guide at https://docs.brew.sh/FAQ#how-do-i-uninstall-homebrew
- Remove Oh My Zsh: `rm -rf ~/.oh-my-zsh`
- Remove Neovim config: `rm -rf ~/.config/nvim`
- Remove dotfiles: `rm -rf ~/dotfiles`
- Remove Zsh plugins: `rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting`
- Remove Tmux TPM: `rm -rf ~/.tmux/plugins/tpm`
- Change shell back to bash: `chsh -s /bin/bash`
- Uninstall OpenCode: Follow OpenCode's uninstallation instructions

Note: This project is licensed under GPL-3.0. See LICENSE for details.
