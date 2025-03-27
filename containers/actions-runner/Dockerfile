# Based on the image by onedr0p
# https://github.com/onedr0p/containers/blob/main/apps/actions-runner/Dockerfile
FROM ghcr.io/actions/actions-runner:2.323.0@sha256:831a2607a2618e4b79d9323b4c72330f3861768a061c2b92a845e9d214d80e5b

ENV HOMEBREW_NO_ANALYTICS=1 \
    HOMEBREW_NO_ENV_HINTS=1 \
    HOMEBREW_NO_INSTALL_CLEANUP=1 \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    DEBIAN_FRONTEND="noninteractive" \
    APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn

USER root

RUN \
    apt-get update && apt-get upgrade -y \
    && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        gcc \
        jo \
        make \
        moreutils \
        unrar \
        wget \
        zip \
        g++ \
        cmake \
    && rm -rf /var/lib/apt/lists/*

RUN curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose \
    && chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

ENV NVM_DIR /usr/local/nvm
ENV NODE_VERSION v20.10.0

RUN mkdir -p $NVM_DIR \
    && curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash \
    && . $NVM_DIR/nvm.sh \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default

ENV NODE_PATH $NVM_DIR/versions/node/$NODE_VERSION/lib/node_modules
ENV PATH      $NVM_DIR/versions/node/$NODE_VERSION/bin:$PATH

USER runner

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
