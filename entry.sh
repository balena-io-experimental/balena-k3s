#!/usr/bin/env bash

set -euo pipefail

kubectl delete secret image-pull-secret 2>/dev/null || true

if [ -n "${DOCKER_USERNAME:-}" ] && [ -n "${DOCKER_PASSWORD:-}" ]; then
	echo "Creating DockerHub image-pull-secret from environment variables"
	kubectl create secret docker-registry image-pull-secret \
		--docker-server='https://index.docker.io/v1/' \
		--docker-username="${DOCKER_USERNAME}" \
		--docker-password="${DOCKER_PASSWORD}"
fi

while true; do
	# recursively run envsubst on all files in /kubernetes
	find /kubernetes -type f -name "*.yml" -exec sh -c 'envsubst < "$1" > "$1.tmp" && mv "$1.tmp" "$1"' _ {} \;
	kubectl apply -k /kubernetes
	sleep ${UPDATE_INTERVAL:-600}
done
