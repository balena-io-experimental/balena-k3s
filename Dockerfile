FROM debian:bullseye-slim

# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# https://github.com/k3s-io/k3s/releases
ARG K3S_RELEASE=v1.25.4+k3s1

RUN case "$(uname -m)" in \
        "aarch64"|"arm64") ARTIFACT_NAME="k3s-arm64" ;; \
        "armv7"|"armhf") ARTIFACT_NAME="k3s-armhf" ;; \
        *) ARTIFACT_NAME="k3s" ;; \
    esac && \
    curl -fsSL -o /usr/bin/k3s "https://github.com/k3s-io/k3s/releases/download/${K3S_RELEASE/+/%2B}/${ARTIFACT_NAME}" && \
    chmod +x /usr/bin/k3s && \
    k3s --version

COPY entry.sh /

RUN chmod +x /entry.sh

CMD [ "/entry.sh" ]

ENV K3S_ROLE agent
