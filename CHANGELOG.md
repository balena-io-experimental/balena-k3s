# Changelog

All notable changes to this project will be documented in this file
automatically by Versionist. DO NOT EDIT THIS FILE MANUALLY!
This project adheres to [Semantic Versioning](http://semver.org/).

# v0.2.7
## (2023-12-19)

* Remove repo config from flowzone.yml [Kyle Harding]

# v0.2.6
## (2023-09-18)

* Simplifies the sample application deployment guide. [Carlo Miguel F. Cruz]

# v0.2.5
## (2023-09-15)

* Improve kubeconfig copy steps [Kyle Harding]

# v0.2.4
## (2023-09-01)

* Update to latest arkade and build from source [Kyle Harding]

# v0.2.3
## (2023-09-01)

* Remove bastion entrypoint script and kubernetes manifests [Kyle Harding]

# v0.2.2
## (2023-09-01)

* Add balena.yml for release versioning [Kyle Harding]
* Only apply kubernetes manifests if UPDATE_INTERVAL is provided [Kyle Harding]
* Create a custom entrypoint for the server container [Kyle Harding]
* Make update interval optional and ignore failures [Kyle Harding]

# v0.2.1
## (2023-07-14)

* Remove balena-specific example deployment files [Kyle Harding]

# v0.2.0
## (2023-07-14)

* Image pull secrets should be defined as kubernetes manifests. [Carlo Miguel F. Cruz]

# v0.1.1
## (2023-07-14)

* Updates some Kubernetes client tools. [Carlo Miguel F. Cruz]

# v0.1.0
## (2023-06-23)

* Add Flowzone workflow [Kyle Harding]
* Deploy each node as a server in an HA etcd cluster [Kyle Harding]
* Uses cert-manager for self-signed HTTPS certificates. [Carlo Miguel F. Cruz]
* Add monitor deployment. Delete API until fully working. [Carlo Miguel F. Cruz]
* Apply K8s manifests using kustomizations every set interval. [Carlo Miguel F. Cruz]
* Add balena-apii, ingress and postgresql k8s deployments. [Carlo Miguel F. Cruz]
