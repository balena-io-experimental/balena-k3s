FROM debian:bullseye-slim

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

# hadolint ignore=DL3008
RUN apt-get update && apt-get install --no-install-recommends -y \
    ca-certificates \
    curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG ARKADE_URL="https://raw.githubusercontent.com/alexellis/arkade/63ce1ed3f926920bbc98bfe5540598c7e2e81d20/get.sh"
ARG ARKADE_SHA256="17338aa29114f312671671de7afb90a74617e1ff31f925cd52f7b0e884774b89"

RUN curl -sLS -o get.sh "${ARKADE_URL}" && \
    echo "${ARKADE_SHA256}  get.sh" | sha256sum -c - && \
    chmod +x get.sh && \
    ./get.sh

ENV PATH "${PATH}:/root/.arkade/bin/"

RUN arkade get --progress=false \
        k3s@v1.26.1+k3s1

COPY entry.sh /

RUN chmod +x /entry.sh

CMD [ "/entry.sh" ]

ENV K3S_ROLE agent
