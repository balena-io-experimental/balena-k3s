#!/usr/bin/env bash

set -euo pipefail

while true; do
  # recursively run envsubst on all files in /kubernetes
  find /kubernetes -type f -name "*.yml" -exec sh -c 'envsubst < "$1" > "$1.tmp" && mv "$1.tmp" "$1"' _ {} \;
  kubectl apply -k /kubernetes
  sleep ${UPDATE_INTERVAL:-600}
done
