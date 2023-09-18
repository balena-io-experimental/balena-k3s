# balena-k3s

Run a Kubernetes cluster on balenaCloud via k3s!

## Requirements

Embedded etcd (HA) may have performance issues on slower disks such as Raspberry Pis running with SD cards
so a reasonably performant VPS or Intel NUC is suggested.

## Getting Started

1. Add first device to the fleet, wait for cluster to initialize
2. Set fleet environment variable `K3S_URL` to the HTTPS host and port of the first device, e.g. `https://192.168.1.105:6443`
3. Add additional devices, wait for them to join the cluster
4. Start a terminal in the `bastion` service and run `kubectl get nodes`

## Usage

### Environment Variables

The following environment variables are supported on the fleet/device:

- (server) `K3S_TOKEN`: Used to authenticate nodes and ensure secure communication between them
- (server) `K3S_URL`: HTTPS host and port of the first node(s) that initialized the cluster, e.g. `https://192.168.1.105:6443`
- (server) `EXTRA_K3S_SERVER_ARGS`: Optional extra args provided to `k3s server`, e.g. `--tls-san=35.174.115.184`

### Networking

#### Ports

The following ports must be open between the nodes for communication:

- `6443:6443` Kubernetes API Server
- `2379:2379` etcd client requests
- `2380:2380` etcd peer communication

The following ports should be open to expose ingress web services:

- `80:80` Ingress controller port 80
- `443:443` Ingress controller port 443

#### Firewalls/NAT

If nodes are separated by firewalls or NATs, you might need to specify the public facing IP via `EXTRA_K3S_SERVER_ARGS=--tls-san=35.174.115.184`
and make sure the communication ports above are open between the nodes.

### On-device troubleshooting

There is a bastion service with a number of kubernetes tools preinstalled.

Just open a terminal in the `bastion` service via the balenaCloud dashboard or run

```bash
balena ssh $UUID bastion
kubectl get nodes
```

### Deploy example application

After deploying the app above to a fleet of devices, it's time to start pushing some kubernetes applications!

This guide deploys a sample Caddy server into your new Kubernetes cluster and makes it accessible through an ingress with a self-signed TLS certificate.

Requires:

- `kubectl` to run kubernetes commands against your cluster
- the balena UUID of one of your server nodes

1. Clone this repository, including the example [sample_cluster](./sample_cluster) kubernetes manifests.

2. Copy the configuration file with keys to authenticate your workstation to the cluster.

```bash
UUID=cf38d3c61c39429ab379e0a87d3689dd
echo 'find /mnt/data/docker/volumes -name kubeconfig.yaml -exec cat {} \; ; exit' | balena ssh $UUID | grep -v '===' | grep -v 'Welcome' > kubeconfig.yaml
export KUBECONFIG="${PWD}/kubeconfig.yaml"
```

3. Open a tunnel to the controller port of the cluster node, keep this running in another tab.

```bash
UUID=cf38d3c61c39429ab379e0a87d3689dd
balena tunnel $UUID -p 6443:6443
```

4. Check if the cluster is reachable over the tunnel.

```bash
kubectl get nodes
```

5. Generate an image pull secret to allow Kubernetes to pull from private docker registries.
```bash
REGISTRY_HOST='https://index.docker.io/v1/'
REGISTRY_USERNAME=myDockerUsername
REGISTRY_PASSWORD=myDockerAccessToken
kubectl create secret docker-registry image-pull-secret \
    --docker-server="${REGISTRY_HOST}" \
    --docker-username="${REGISTRY_USERNAME}" \
    --docker-password="${REGISTRY_PASSWORD}" \
    --dry-run=client -o yaml > sample_cluster/image-pull-secret.yml
```

6. Apply manifests using Kustomization file and wait for a few minutes for the resources to be provisioned.

```bash
kubectl apply -k sample_cluster/
```

7. Save the self-signed CA certificate and import it into your browser.  This will allow you to access the sample Caddy server using https.
```bash
kubectl get secret selfsigned-cert -o jsonpath="{.data.ca\.crt}" | base64 --decode > ca.crt
```

8. Add `caddy.balena.local` to your local DNS resolver pointing to the IP of your device. This will allow you to access https://caddy.balena.local from your workstation.

9. Optional: Delete the resources deployed in the cluster.
```
kubectl delete -k sample_cluster/
```


#### Kustomizations


A Kustomization is a file or directory that describes how to customize Kubernetes resources. Kustomization allows for easy and efficient management of Kubernetes configurations across different environments and deployments.


#### Self-Signed TLS Certificate

You can use cert-manager to provision self-signed certificates for your Kubernetes cluster. You can import the CA of the self-signed certificates into your web browser by exporting it from Kubernetes and saving it into a file. You can then import this CA certificate through your browser's security settings.

#### Image Pull Secrets

An image pull secret is a Kubernetes object that contains the necessary credentials to authenticate with a container registry and pull container images. It is used to securely authenticate and authorize access to private container images stored in a registry. Image pull secrets are typically used when deploying applications that require access to private or restricted container images.

Here is a sample image pull secret manifest file that was generated using the sample command in step 5 of the sample application deployment guide.

```yaml
apiVersion: v1
data:
  .dockerconfigjson: eyJhdXRocyI6eyJodHRwczovL2luZGV4LmRvY2tlci5pby92MS8iOnsidXNlcm5hbWUiOiJteURvY2tlclVzZXJuYW1lIiwicGFzc3dvcmQiOiJteURvY2tlckFjY2Vzc1Rva2VuIiwiYXV0aCI6ImJYbEViMk5yWlhKVmMyVnlibUZ0WlRwdGVVUnZZMnRsY2tGalkyVnpjMVJ2YTJWdSJ9fX0=
kind: Secret
metadata:
  creationTimestamp: null
  name: image-pull-secret
type: kubernetes.io/dockerconfigjson
```


## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.
