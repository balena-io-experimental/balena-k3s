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

#### MDNS

If using a local MDNS name instead of a TLD, add the following records to your local DNS resolver pointing to the IP of your device.

- `caddy.bob.local`
- `api.bob.local`

#### Self-Signed TLS Certificate

You can use cert-manager to provision self-signed certificates for your Kubernetes cluster. You can import the CA of the self-signed certificates into your web browser by exporting it from Kubernetes and saving it into a file. You can then import this CA certificate through your browser's security settings.

You can use the commands below to extract the certificate from the cluster based on the example Kubernetes configuration that comes with this project.

```bash
SERVER_IP=192.168.1.105
echo 'kubectl get secret selfsigned-cert -o jsonpath="{.data.ca\.crt}" | base64 --decode > ca.crt' | balena ssh ${SERVER_IP} bastion
echo 'cat ca.crt' | balena ssh ${SERVER_IP} bastion > ca.crt
```

### On-device troubleshooting

There is a bastion service with a number of kubernetes tools preinstalled.

Just open a terminal in the `bastion` service via the balenaCloud dashboard or run

```bash
balena ssh $UUID bastion
kubectl get nodes
```

### Deploy example application

After deploying the app above to a fleet of devices, it's time to start pushing some kubernetes applications!

Requires:

- `kubectl` to run kubernetes commands against your cluster
- `envsubst` to substitute environment variables in the example kubernetes manifests
- the balena UUID of one of your server nodes

1. Clone this repository, including the example [kubernetes](./kubernetes) manifests.
2. Copy the configuration file with keys to authenticate your workstation to the cluster:

```bash
UUID=cf38d3c61c39429ab379e0a87d3689dd
echo 'find /mnt/data/docker/volumes -name kubeconfig.yaml -exec cat {} \; ; exit' | balena ssh $UUID | grep -v '===' | grep -v 'Welcome' > kubeconfig.yaml
export KUBECONFIG="${PWD}/kubeconfig.yaml"
```

3. Open a tunnel to the controller port of the cluster node, keep this running in another tab

```bash
UUID=cf38d3c61c39429ab379e0a87d3689dd
balena tunnel $UUID -p 6443:6443
```

4. Check if the cluster is reachable over the tunnel

```bash
kubectl get nodes
```

5. Apply manifests while substituting environment variables as needed:

```bash
find ./kubernetes -name "*.yml" -exec sh -c 'envsubst < "$1"' _ {} \; | kubectl apply -f -
```

#### Image Pull Secrets

If you need to use image pull secrets to pull images from private repositories,
you can include an image pull secret manifest for that registry in your Kubernetes
kustomization.

Start by generating the `.dockerconfigjson` data for the target registry.
The following commands should generate the configuration data in base64 format
and set the generated configuration into an environment variable for your fleet or device.

```bash
REGISTRY_HOST='https://index.docker.io/v1/'
REGISTRY_USERNAME=myDockerUsername
REGISTRY_PASSWORD=myDockerAccessToken
IMAGE_PULL_SECRET=$(kubectl create secret docker-registry image-pull-secret \
    --docker-server="${REGISTRY_HOST}" \
    --docker-username="${REGISTRY_USERNAME}" \
    --docker-password="${REGISTRY_PASSWORD}" \
    --dry-run=client -o jsonpath='{.data.\.dockerconfigjson}')
```

Add a image pull secret YAML file in your kubernetes directory and include
this file in the kustomization files list. Here is a sample image pull secret
manifest file.

```yaml
apiVersion: v1
data:
  .dockerconfigjson: ${IMAGE_PULL_SECRET}
kind: Secret
metadata:
  creationTimestamp: null
  name: image-pull-secret
type: kubernetes.io/dockerconfigjson
```

The environment variable placeholder in the image pull secret YAML file
should match the environment variable containing the `.dockerconfigjson`
data.

## Contributing

Please open an issue or submit a pull request with any features, fixes, or changes.
