#!/bin/sh

set -eu

# https://docs.k3s.io/cli/server
# https://docs.k3s.io/cli/agent

if [ -z "${K3S_TOKEN:-}" ]; then
    echo "K3S_TOKEN is not set. Set it as a fleet variable." >&2
    exit 1
fi

case "${K3S_ROLE:=agent}" in
server)
    # k3s server also reads K3S_URL and joins it as a second server. Unset it.
    unset K3S_URL
    ;;
agent)
    if [ -z "${K3S_URL:-}" ]; then
        echo "K3S_URL is not set. Set it as a fleet variable, e.g. https://192.168.1.10:6443" >&2
        exit 1
    fi
    ;;
*)
    echo "K3S_ROLE must be 'server' or 'agent', got '${K3S_ROLE}'." >&2
    exit 1
    ;;
esac

# balenaOS runs cgroup v1. Kubernetes 1.35+ kubelets refuse cgroup v1 by default.
# https://kubernetes.io/docs/concepts/architecture/cgroups/
# shellcheck disable=SC2086
exec /bin/k3s "${K3S_ROLE}" --kubelet-arg=fail-cgroupv1=false ${EXTRA_K3S_ARGS:-}
