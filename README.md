# balena-k3s

Run a Kubernetes cluster on balenaCloud via k3s!

## Usage

### Environment Variables

The following environment variables are supported:

- (All Services) `K3S_TOKEN`: Used to authenticate nodes and ensure secure communication between them
- (Server) `EXTRA_K3S_SERVER_ARGS`: Optional extra args provided to `k3s server`
- (Agent) `K3S_URL`: Full URL of the k3s API server (e.g. `https://10.0.3.98:6443`)
- (Bastion) `DOCKER_USERNAME`: Required if using private images on DockerHub
- (Bastion) `DOCKER_PASSWORD`: Required if using private images on DockerHub

### MDNS

If using a local MDNS name instead of a TLD, add the following records to your local DNS resolver pointing to the IP of your device.

- `caddy.bob.local`
- `api.bob.local`

### Self-Signed TLS Certificate

You can use cert-manager to provision self-signed certificates for your Kubernetes cluster. You can import the CA of the self-signed certificates into your web browser by exporting it from Kubernetes and saving it into a file.  You can then import this CA certificate through your browser's security settings.

You can use the commands below to extract the certificate from the cluster based on the example Kubernetes configuration that comes with this project.

```bash
SERVER_IP=10.0.3.98
echo 'kubectl get secret selfsigned-cert -o jsonpath="{.data.ca\.crt}" | base64 --decode > ca.crt' | balena ssh ${SERVER_IP} bastion
echo 'cat ca.crt' | balena ssh ${SERVER_IP} bastion > ca.crt
```

### On-device development

There is a bastion service with a number of kubernetes tools preinstalled.

Just open a terminal in the `bastion` service via the balenaCloud dashboard or run

```bash
balena ssh $UUID bastion
```

### Remote development

If you have access to the IP of the server, you can use your workstation to run kubernetes commands.

First, copy the configuration from the server to your workstation. Keep this file secure!

```bash
SERVER_IP=10.0.3.98 ; echo 'cat /output/kubeconfig.yaml' | balena ssh "${SERVER_IP}" server | sed "s/127.0.0.1/${SERVER_IP}/" > kubeconfig.yaml
```

Then set your kubeconfig path and run any commands.

```bash
KUBECONFIG="${PWD}/kubeconfig.yaml" kubectl get nodes
```

