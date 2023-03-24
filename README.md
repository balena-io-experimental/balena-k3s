# balena-k3s

Run a Kubernetes cluster on balenaCloud via k3s!

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

### MDNS

Add the following records to your local DNS resolver pointing to the IP of your device.

- `caddy.bob.local`
- `api.bob.local`

### Registry secrets

```bash
kubectl create secret docker-registry image-pull-secret \
    --docker-server='https://index.docker.io/v1/' \
    --docker-username=<your-name> \
    --docker-password=<your-pword> \
    --docker-email=<your-email>
```
