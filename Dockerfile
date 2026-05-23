ARG PI_VERSION=0.75.5
ARG EXTENSIONS="npm:pi-hashline-readmap npm:pi-btw npm:pi-smart-fetch npm:@heart-of-gold/toolkit npm:pi-extmgr"

FROM node:22-alpine

ARG PI_VERSION
ARG EXTENSIONS

# Install OS dependencies with temporary edge repo for uv/ast-grep/nushell
RUN apk add --no-cache \
    --repository https://dl-cdn.alpinelinux.org/alpine/edge/community \
    git \
    curl \
    ca-certificates \
    ripgrep \
    fd \
    python3 \
    git \
    jq \
    build-base \
    openssh-client \
    uv \
    ast-grep \
    nushell \
    difftastic \
    shellcheck \
    yq \
    scc

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
