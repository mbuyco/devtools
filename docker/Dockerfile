
# Default platform is `linux/arm64`
FROM --platform=${BUILDPLATFORM:-linux/arm64} ubuntu:24.04

ARG DEBIAN_FRONTEND
ARG IMAGE_AUTHOR
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
      ca-certificates \
      curl \
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

# Install TPM (tmux plugin manager)
RUN mkdir -p $HOME/.tmux/plugins \
  && git clone --depth=1 https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm || true

# Add entrypoint script (handles optional cloning of NVIM_REPO)
COPY --chown=dev:dev entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Minimal .tmux.conf to enable tpm (the user's config may replace this when they mount or clone)
RUN printf "set -g @plugin 'tmux-plugins/tpm'\nset -g @plugin 'tmux-plugins/tmux-sensible'\nrun -b '~/.tmux/plugins/tpm/tpm'\n" > $HOME/.tmux.conf

# Expose editor-friendly environment variable defaults
ENV NVIM_CONFIG_DIR=/home/dev/.config/nvim
ENV NVIM_REPO="${NVIM_REPO:-}"
ENV NVIM_FORCE="${NVIM_FORCE:-0}"

# Switch back to root only to set permissions if needed (not required here),
# then default to dev user for safety at runtime.
USER dev

ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
CMD [ "zsh" ]
