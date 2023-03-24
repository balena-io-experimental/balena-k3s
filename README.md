# balena-k3s

Run a Kubernetes cluster on balenaCloud via k3s!

## Usage

### Top Level Domain

The default top level domain (TLD) is `bob.local` so services with ingress can expose `{service}.bob.local`.

Change this to a custom top level domain, or a different local MDNS name, via the `TLD` environment variable.

### MDNS

If using a local MDNS name, add the following records to your local DNS resolver pointing to the IP of your device.

- `caddy.bob.local`
- `api.bob.local`

### Registry secrets

In order to pull private docker images, you'll need to set some environment variables on the `bastion` service.

- `DOCKER_USERNAME`
- `DOCKER_PASSWORD`

The `bastion` service will [create a docker-registry kubernetes secret for you](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line).

## Remote development

There is a bastion service with a number of kubernetes tools preinstalled.

Just open a terminal in the `bastion` service via the balenaCloud dashboard or run

```bash
balena ssh $UUID kubectl
```

## Local development

If you have local access to the IP of the server, you can use your workstation to run kubernetes commands.

First, copy the configuration from the server to your workstation. Keep this file secure!

```bash
SERVER_IP=10.0.3.81 ; echo 'cat /output/kubeconfig.yaml' | balena ssh "${SERVER_IP}" server | sed "s/127.0.0.1/${SERVER_IP}/" > k3s.yaml
```

Then set your kubectl config path and run any commands.

```bash
KUBECONFIG="${PWD}/k3s.yaml" kubectl get nodes
```
