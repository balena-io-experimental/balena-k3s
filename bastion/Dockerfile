FROM golang:1.21.0 AS arkade

WORKDIR /src

ARG ARKADE_VERSION=0.10.1
ARG CGO_ENABLED=0

ADD https://github.com/alexellis/arkade/archive/refs/tags/${ARKADE_VERSION}.tar.gz ./

RUN tar xvf ${ARKADE_VERSION}.tar.gz --strip-components=1 && make build

FROM debian:bullseye-slim

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl \
    dnsutils \
    gettext-base && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=arkade /src/arkade /usr/local/bin/arkade

ENV PATH "${PATH}:/root/.arkade/bin/"

RUN arkade version && \
    arkade get --progress=false \
    flux@v0.39.0 \
    helm@v3.11.1 \
    jq@jq-1.6 \
    k3sup@0.12.12 \
    k9s@v0.27.2 \
    kubectl@v1.26.2 \
    kustomize@v5.0.3 \
    yq@v4.30.8

CMD [ "tail" , "-f", "/dev/null" ]
