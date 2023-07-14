#!/bin/sh

set -eu

# https://docs.k3s.io/cli/server
# https://docs.k3s.io/datastore/ha-embedded

if [ -n "${K3S_URL:-}" ]; then
    # shellcheck disable=SC2086
    exec /bin/k3s server --server "${K3S_URL}" ${EXTRA_K3S_SERVER_ARGS:-}
else
    # shellcheck disable=SC2086
    exec /bin/k3s server --cluster-init ${EXTRA_K3S_SERVER_ARGS:-}
fi
