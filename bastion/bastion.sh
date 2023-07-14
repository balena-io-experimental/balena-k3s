#!/usr/bin/env bash

set -euo pipefail

# recursively run envsubst on all files in /kubernetes
find /kubernetes -type f -name "*.yml" -exec sh -c 'envsubst < "$1" > "$1.tmp" && mv "$1.tmp" "$1"' _ {} \;

# only apply manifests if update interval is set, otherwise we could overwrite manual changes
if [ -n "${UPDATE_INTERVAL:-}" ]
then
  while true; do
    kubectl apply -k /kubernetes || true
    sleep "${UPDATE_INTERVAL}"
  done
fi

sleep infinity
