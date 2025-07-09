# Claude Code Container with Dotfiles Integration
FROM ubuntu:22.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Basic tools
    curl \
    wget \
    git \
    unzip \
    sudo \
    ca-certificates \
    # Shell tools
    zsh \
    # Development tools
    build-essential \
    # Network tools (for firewall setup)
    iptables \
    # Node.js for Claude Code
    nodejs \
    npm \
    # Python for various tools
    python3 \
    python3-pip \
    # Additional utilities
    jq \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
ARG USERNAME=claude
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Switch to non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | sh

# Copy and install dotfiles
COPY --chown=$USERNAME:$USERNAME . /tmp/dotfiles
RUN cd /tmp/dotfiles && ./install.sh

# Copy security scripts
COPY --chown=$USERNAME:$USERNAME scripts/init-firewall.sh /home/$USERNAME/init-firewall.sh
COPY --chown=$USERNAME:$USERNAME scripts/entrypoint.sh /home/$USERNAME/entrypoint.sh
RUN chmod +x /home/$USERNAME/init-firewall.sh /home/$USERNAME/entrypoint.sh

# Set up shell environment
ENV SHELL=/bin/zsh
ENV USER=$USERNAME

# Create workspace directory
RUN mkdir -p /home/$USERNAME/workspace

# Expose no ports (security)
EXPOSE

# Set entrypoint
ENTRYPOINT ["/home/claude/entrypoint.sh"]
CMD ["zsh"]