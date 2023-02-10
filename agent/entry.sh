#!/usr/bin/env bash

set -euo pipefail

if [ -f "/var/lib/rancher/k3s/server/node-token" ]
then
    K3S_TOKEN="$(</var/lib/rancher/k3s/server/node-token)"
    export K3S_TOKEN
fi

echo "K3S_ROLE: ${K3S_ROLE:-}"
echo "K3S_URL: ${K3S_URL:-}"
echo "K3S_TOKEN: ${K3S_TOKEN:-}"

exec k3s "${K3S_ROLE}"
