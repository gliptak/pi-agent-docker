ARG PI_VERSION=0.79.1
ARG EXTENSIONS="npm:pi-hashline-readmap npm:pi-btw npm:pi-smart-fetch git:github.com/gliptak/kitout npm:@heart-of-gold/toolkit npm:pi-extmgr"

FROM node:26-bookworm-slim

ARG PI_VERSION
ARG EXTENSIONS

# Install system dependencies from Debian repos
# fd-find is packaged as fdfind; we symlink to fd for compatibility
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git \
    curl \
    ca-certificates \
    ripgrep \
    fd-find \
    python3 \
    python3-pip \
    jq \
    build-essential \
    openssh-client \
    shellcheck \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

# Grant node user passwordless sudo
RUN echo "node ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/node && chmod 440 /etc/sudoers.d/node

# Install uv (Python package manager) via pip
RUN pip3 install uv --break-system-packages

# Install yq (YAML/XML/JSON processor) from GitHub release
RUN set -eux; \
    arch=$(dpkg --print-architecture); \
    curl -fsSL "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${arch}" -o /usr/local/bin/yq; \
    chmod +x /usr/local/bin/yq

# Install Rust/Go tool binaries from GitHub releases
RUN set -eux; \
    arch=$(uname -m); \
    case "$arch" in \
        x86_64) ltag="x86_64"; stag="x86_64" ;; \
        aarch64|arm64) ltag="aarch64"; stag="arm64" ;; \
        *) echo "unsupported arch: $arch"; exit 1 ;; \
    esac; \
    \
    # nushell - asset name includes version, resolve via API \
    ver=$(curl -sL "https://api.github.com/repos/nushell/nushell/releases/latest" | \
        python3 -c "import json,sys; print(json.load(sys.stdin)['tag_name'])"); \
    curl -fsSL "https://github.com/nushell/nushell/releases/download/${ver}/nu-${ver}-${ltag}-unknown-linux-gnu.tar.gz" -o /tmp/nu.tar.gz; \
    tar xzf /tmp/nu.tar.gz -C /usr/local/bin --strip-components=1 "nu-${ver}-${ltag}-unknown-linux-gnu/nu"; \
    \
    # difftastic - stable asset name, latest/download works \
    curl -fsSL "https://github.com/Wilfred/difftastic/releases/latest/download/difft-${ltag}-unknown-linux-gnu.tar.gz" -o /tmp/difft.tar.gz; \
    tar xzf /tmp/difft.tar.gz -C /usr/local/bin; \
    \
    # scc - flat archive, extract only the binary \
    curl -fsSL "https://github.com/boyter/scc/releases/latest/download/scc_Linux_${stag}.tar.gz" -o /tmp/scc.tar.gz; \
    tar xzf /tmp/scc.tar.gz -C /usr/local/bin scc; \
    \
    rm -rf /tmp/*.tar.gz

# Install ast-grep (structural code search) via npm
RUN npm install -g @ast-grep/cli

# Pinned Pi agent install
RUN npm install -g @earendil-works/pi-coding-agent@${PI_VERSION}

# Switch to node user for runtime
USER node
WORKDIR /work
ENV HOME=/home/node
ENV PATH="/home/node/.local/bin:${PATH}"
ENV PI_SKIP_VERSION_CHECK=1
ENV EXTENSIONS=${EXTENSIONS}

# Copy install-pi-extensions.sh to known location
COPY --chown=node install-pi-extensions.sh /home/node/.local/bin/
RUN chmod +x /home/node/.local/bin/install-pi-extensions.sh

CMD ["/bin/sh", "-c", "install-pi-extensions.sh ${EXTENSIONS} && pi"]
