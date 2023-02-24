#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config

K3S_HOST="$(echo "${K3S_URL}" | awk -F'[/:]' '{print $4}' | xargs dig +short)"

sed -r "s|server: .+$|server: https://${K3S_HOST}:6443|" /output/kubeconfig.yaml > /config/kubeconfig.yaml

kubectl apply -f /kubernetes --recursive

tail -f /dev/null
