# balena-k3s

Run a multi-node [k3s](https://docs.k3s.io/) Kubernetes cluster on a
balenaCloud fleet, then deploy to it from your workstation with `kubectl`,
`helm`, or `flux`.

One device runs the k3s server. Every other device joins as an agent. The
server also runs workloads. The k3s defaults stay on: Traefik ingress,
ServiceLB, and local-path storage.

This is not a highly available setup. If the server device goes down, the
control plane goes down with it.

## Deploy

[![balena deploy button](https://www.balena.io/deploy.svg)](https://dashboard.balena-cloud.com/deploy?repoUrl=https://github.com/balena-io-experimental/balena-k3s)

Or push from a clone:

```bash
balena push <fleet>
```

## Configure

| Variable | Set on | Value |
| --- | --- | --- |
| `K3S_TOKEN` | fleet | A long random secret, e.g. `openssl rand -hex 32` |
| `K3S_URL` | fleet | `https://<server-ip>:6443` |
| `K3S_ROLE` | the server device only | `server` |
| `K3S_NODE_NAME` | device | Optional node name. The default is the hostname |
| `EXTRA_K3S_ARGS` | fleet or device | Optional extra `k3s` args |

1. Set `K3S_TOKEN` on the fleet.
2. Add the first device and set the device variable `K3S_ROLE=server`.
3. Set `K3S_URL` on the fleet to the address of the server device. Use a
   static IP or a DHCP reservation, because agents fail to connect if the
   address changes.
4. Add more devices. They start as agents and join the server.

`K3S_TOKEN` lets any host that knows it join the cluster. Keep it secret.

Set `K3S_NODE_NAME` before a node runs workloads. After a rename, the node
joins as a new node:

- The old node stays `NotReady`. Delete it with `kubectl delete node <old-name>`.
- A local-path volume stays bound to the old node, so its pods cannot start.

## Ports

- TCP 6443 on the server: Kubernetes API, from agents and workstations.
- UDP 8472 between all nodes: flannel VXLAN.
- TCP 10250 between all nodes: kubelet metrics and logs.
- TCP 80 and 443 on any node: Traefik ingress.

See the [k3s networking requirements](https://docs.k3s.io/installation/requirements#networking).

## Connect from your workstation

Copy the kubeconfig from the server device and point it at the server address.
By UUID, `balena device ssh <uuid> k3s` goes through the balenaCloud proxy,
which starts `bash` and does not accept piped commands. The `k3s` image has no
`bash`. Pipe the command to the host OS instead, which works by UUID or by
local address:

```bash
UUID=<server-device-uuid>
SERVER_IP=<server-ip>
CONTEXT=balena-k3s  # name for this cluster in your kubeconfig
balena device ssh "$UUID" <<'EOF' \
  | sed -n '/^apiVersion:/,$p' \
  | sed -e "s/127.0.0.1/${SERVER_IP}/" -e "s/: default$/: ${CONTEXT}/" \
  > kubeconfig.yaml
balena-engine exec $(balena-engine ps -qf name=k3s_) \
  cat /etc/rancher/k3s/k3s.yaml
exit
EOF
export KUBECONFIG="${PWD}/kubeconfig.yaml"
kubectl get nodes -o wide
```

k3s names the cluster, user, and context `default`. The second `sed`
expression renames them to `$CONTEXT`, so the file does not overwrite other
`default` entries when you merge it into `~/.kube/config`.

This kubeconfig has cluster-admin rights. Treat it like a password.

The client certificate in this file is valid for 365 days. k3s renews the
certificate on the device when it starts within 120 days of expiry, but your
copy does not update. Run the command again when `kubectl` reports a
certificate error. See the k3s
[certificate docs](https://docs.k3s.io/cli/certificate).

Away from the LAN, keep `SERVER_IP=127.0.0.1` and open a tunnel in another
terminal:

```bash
balena tunnel "$UUID" -p 6443:6443
```

For on-device troubleshooting, open a host OS terminal and run `kubectl` in the
container:

```bash
balena device ssh "$UUID"
balena-engine exec -it $(balena-engine ps -qf name=k3s_) sh
kubectl get pods -A
```

## Deploy an example app

```bash
helm repo add podinfo https://stefanprodan.github.io/podinfo
helm install podinfo podinfo/podinfo --namespace podinfo --create-namespace \
  --set ingress.enabled=true \
  --set ingress.className=traefik
curl -H 'Host: podinfo.local' "http://${SERVER_IP}/"
```

To manage the cluster with GitOps instead, run
[`flux bootstrap`](https://fluxcd.io/flux/installation/bootstrap/) against the
same kubeconfig.

## Contributing

Please open an issue or submit a pull request with any features, fixes, or
changes.
