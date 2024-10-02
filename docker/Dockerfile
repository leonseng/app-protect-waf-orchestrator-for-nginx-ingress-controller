# syntax=docker/dockerfile:1
ARG AP_WAF_COMPILER_BASE_IMAGE
FROM ${AP_WAF_COMPILER_BASE_IMAGE} AS base

# Installing packages as root
USER root

ENV DEBIAN_FRONTEND="noninteractive"

RUN --mount=type=secret,id=nginx-crt,dst=/etc/ssl/nginx/nginx-repo.crt,mode=0644 \
  --mount=type=secret,id=nginx-key,dst=/etc/ssl/nginx/nginx-repo.key,mode=0644 \
  apt-get update \
  && apt-get install -y \
  apt-transport-https \
  lsb-release \
  ca-certificates \
  wget \
  gnupg2 \
  ubuntu-keyring \
  && wget -qO - https://cs.nginx.com/static/keys/app-protect-security-updates.key | gpg --dearmor | \
  tee /usr/share/keyrings/app-protect-security-updates.gpg >/dev/null \
  && printf "deb [signed-by=/usr/share/keyrings/app-protect-security-updates.gpg] \
  https://pkgs.nginx.com/app-protect-security-updates/ubuntu `lsb_release -cs` nginx-plus\n" | \
  tee /etc/apt/sources.list.d/nginx-app-protect.list \
  && wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90pkgs-nginx \
  && apt-get update \
  && apt-get install -y \
  app-protect-attack-signatures \
  app-protect-bot-signatures \
  app-protect-threat-campaigns \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# non-root default user (UID 101)
USER nginx

# Manual compiler
FROM base AS manual

USER root

RUN rm /etc/apt/sources.list.d/nginx-app-protect.list \
  && apt-get update \
  && apt-get install -y \
  curl \
  vim \
  && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
  && chmod +x kubectl \
  && mv kubectl /usr/local/bin/kubectl \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

USER nginx

# Automated compiler
FROM manual AS auto

ARG ACTIONS_RUNNER_VERSION=2.319.1

USER root

RUN mkdir /actions-runner

WORKDIR /actions-runner

COPY start.sh start.sh

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y jq \
  && curl -o actions-runner-linux-x64-$ACTIONS_RUNNER_VERSION.tar.gz -L https://github.com/actions/runner/releases/download/v2.319.1/actions-runner-linux-x64-$ACTIONS_RUNNER_VERSION.tar.gz \
  && tar xzf ./actions-runner-linux-x64-$ACTIONS_RUNNER_VERSION.tar.gz \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && ./bin/installdependencies.sh \
  && chown -R nginx:nginx /actions-runner \
  && chmod +x start.sh

USER nginx

ENTRYPOINT ["./start.sh"]
