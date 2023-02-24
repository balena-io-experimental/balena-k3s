#!/usr/bin/env bash

set -euo pipefail

mkdir -p /config

sed -r "s|server: .+$|server: https://$(dig +short server):6443|" /output/kubeconfig.yaml > /config/kubeconfig.yaml

kubectl apply -f /kubernetes --recursive

tail -f /dev/null
