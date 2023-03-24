#!/usr/bin/env bash

set -euo pipefail

set -x

# recursively run envsubst on all files in /kubernetes
find /kubernetes -type f -name "*.yml" -exec sh -c 'envsubst < "$1" > "$1.tmp" && mv "$1.tmp" "$1"' _ {} \;

kubectl apply -f /kubernetes --recursive

kubectl delete secret image-pull-secret 2>/dev/null || true

kubectl create secret docker-registry image-pull-secret \
    --docker-server='https://index.docker.io/v1/' \
    --docker-username="${DOCKER_USERNAME}" \
    --docker-password="${DOCKER_PASSWORD}" \
    --docker-email="${DOCKER_EMAIL}"

tail -f /dev/null
