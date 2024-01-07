# Kubernetes

This folder holds the kubernetes GitOps configuration for the maintainers' dedicated server.  
It manages services such as the demo instance and preview environments.

### Bootstrap

1. Boot the Hetzner server into the recovery image and connect via SSH
2. Install debian 12 through https://github.com/terem42/zfs-hetzner-vm
3. Ssh into the new install
4. Install k3s with this command:

```
curl -sfL https://get.k3s.io | sh -s - --disable-cloud-controller --disable-helm-controller --disable=traefik,local-storage,servicelb
```

5. Bootstrap flux: `kubectl apply --kustomize ./bootstrap`
6. Apply the cluster config: `kubectl apply --kustomize ./flux/config`
