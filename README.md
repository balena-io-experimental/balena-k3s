# balena-kube

Run a Kubernetes cluster on balenaCloud via k3s!

## kubectl

Once the server is up and running, install the kube config on your workstation:

```bash
echo 'cat /etc/rancher/k3s/k3s.yaml' | balena ssh 192.168.1.167 agent | sed 's/127.0.0.1/192.168.1.167/' > k3s.yaml
export KUBECONFIG="${PWD}/k3s.yaml"
kubectl get nodes
```
