ARG PI_VERSION=0.72.0
ARG EXTENSIONS="npm:pi-hashline-readmap npm:pi-extmgr npm:@juicesharp/rpiv-btw npm:@heart-of-gold/toolkit"

FROM node:22-alpine

ARG PI_VERSION
ARG EXTENSIONS

# Add edge/community temporarily for uv, ast-grep, nushell, etc. (not in stable Alpine repos)
RUN echo "https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache \
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
        scc \
    && rm -rf /var/cache/apk/* && \
    sed -i '/edge\/community/d' /etc/apk/repositories

# Pinned Pi agent install (system-wide as root)
RUN npm install -g @mariozechner/pi-coding-agent@${PI_VERSION}

# Copy install-pi-extensions.sh to known location
COPY install-pi-extensions.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/install-pi-extensions.sh

# Switch to node user for runtime
USER node

WORKDIR /work
ENV HOME=/home/node
ENV PATH="/home/node/.local/bin:${PATH}"
ENV PI_SKIP_VERSION_CHECK=1
ENV EXTENSIONS=${EXTENSIONS}

CMD ["/bin/sh", "-c", "/usr/local/bin/install-pi-extensions.sh ${EXTENSIONS} && pi"]
