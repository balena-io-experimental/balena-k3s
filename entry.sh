#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config

sed "s|server: .+$|server: ${K3S_URL}|" /output/kubeconfig.yaml > /config/kubeconfig.yaml

kubectl apply -f /kubernetes --recursive

tail -f /dev/null
