# Default platform is `linux/arm64`
FROM --platform=${BUILDPLATFORM:-linux/arm64} ubuntu:24.04

ARG DEBIAN_FRONTEND
ARG DOTFILES_REPO
ARG IMAGE_AUTHOR
ARG NVIM_REPO
ARG USER_GID
ARG USER_UID

LABEL org.opencontainers.image.authors="${IMAGE_AUTHOR}"
LABEL org.opencontainers.image.description="Lightweight devtools container"

# Keep layers small and secure:
ENV TZ=Etc/UTC \
    HOME=/home/dev \
    XDG_DATA_HOME=/home/dev/.local/share \
    LANG=C.UTF-8

# Install minimal build deps
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
      build-essential \
      ca-certificates \
      curl \
      fzf \
      gnupg \
      lsb-release \
      git \
      sudo \
      wget \
      unzip \
      ca-certificates \
      locales \
      procps \
  && rm -rf /var/lib/apt/lists/*

# Set locale
RUN sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
  && locale-gen en_US.UTF-8

# Install Neovim AppImage (latest stable)
RUN NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases \
  | grep '"tag_name": "v0.11.' \
  | sed -E 's/.*"v(0\.11\.[0-9]+)".*/\1/' \
  | sort -V \
  | tail -n1) && \
  echo "Installing Neovim version $NVIM_VERSION" && \
  ARCH=linux-arm64 && \
  curl -LO https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/nvim-${ARCH}.tar.gz && \
  tar xzf nvim-${ARCH}.tar.gz && \
  mv nvim-${ARCH} /usr/local/nvim-$VERSION && \
  ln -s /usr/local/nvim-$VERSION/bin/nvim /usr/local/bin/nvim && \
  rm nvim-${ARCH}.tar.gz

# Install essential runtime packages (zsh and tmux)
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    openssh-client \
    zsh \
    tmux \
  && rm -rf /var/lib/apt/lists/*

# Install Node.js LTS (NodeSource) - supports both amd64 and arm64
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
  && apt-get install -y --no-install-recommends nodejs \
  && rm -rf /var/lib/apt/lists/*

# Create non-root user 'dev' and setup directories
RUN groupadd --gid ${USER_GID} dev || true \
  && useradd --create-home --uid ${USER_UID} --gid ${USER_GID} --shell /usr/bin/zsh dev \
  && usermod -aG sudo dev \
  && echo "dev ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/dev-nopasswd \
  && chmod 0440 /etc/sudoers.d/dev-nopasswd

WORKDIR /home/dev

# Install oh-my-zsh non-interactively for user dev, and set up basic zshrc
USER dev
ENV PATH="$HOME/.local/bin:$PATH"
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true \
  && git -C $HOME/.oh-my-zsh pull 2>/dev/null || true \
  && cp -n $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc || true

# Install zsh plugins
RUN git clone https://github.com/zsh-users/zsh-autosuggestions $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions || true \
  && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting || true

# Install TPM (tmux plugin manager)
RUN mkdir -p $HOME/.tmux/plugins \
  && git clone --depth=1 https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm || true

# Clone nvim config
RUN mkdir -p "$HOME/.config/nvim" \
  && git clone --depth=1 "$NVIM_REPO" "$HOME/.config/nvim"

# Clone dotfiles
RUN git clone --depth=1 "$DOTFILES_REPO" "$HOME/dotfiles" \
  && if [ -f "$HOME/dotfiles/zsh/.zsh_aliases" ]; then cp -f "$HOME/dotfiles/zsh/.zsh_aliases" "$HOME/.zsh_aliases"; fi \
  && if [ -f "$HOME/dotfiles/zsh/.zshrc" ]; then cp -f "$HOME/dotfiles/zsh/.zshrc" "$HOME/.zshrc"; fi \
  && if [ -f "$HOME/dotfiles/tmux/.tmux.conf" ]; then cp -f "$HOME/dotfiles/tmux/.tmux.conf" "$HOME/.tmux.conf"; fi \
  && if [ -f "$HOME/dotfiles/git/.gitconfig" ]; then cp -f "$HOME/dotfiles/git/.gitconfig" "$HOME/.gitconfig"; fi

# Install OpenCode CLI AI Agent
RUN curl -fsSL https://opencode.ai/install | bash

CMD [ "zsh" ]
