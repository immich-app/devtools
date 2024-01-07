# Kubernetes

This folder holds the kubernetes GitOps configuration for the maintainers' dedicated server.  
It manages services such as the demo instance and preview environments.

### Bootstrap

1. Boot the Hetzner server into the recovery image and connect via SSH
2. Install debian 12 through https://github.com/terem42/zfs-hetzner-vm
3. Ssh into the new install
4. Install k3s with this command:

```
curl -sfL https://get.k3s.io | sh -s - --disable-cloud-controller --disable-helm-controller --disable=traefik,local-storage,servicelb --tls-san 'mich.immich.cloud'
```

5. From your local system, grab the kubeconfig file:

```
scp mich:/etc/rancher/k3s/k3s.yaml ~/.kube/mich.kubeconfig
sed -i '' s/default/mich/g ~/.kube/mich.kubeconfig
sed -i '' s/127.0.0.1/mich.immich.cloud/g ~/.kube/mich.kubeconfig
cp ~/.kube/config ~/.kube/config.bak && KUBECONFIG=~/.kube/config:~/.kube/mich.kubeconfig kubectl config view --flatten > /tmp/config && mv /tmp/config ~/.kube/config
```

6. Bootstrap flux: `kubectl apply --kustomize ./bootstrap`
7. Apply the cluster config: `kubectl apply --kustomize ./flux/config`

## Manual setup

The following things have been set up manually on the debian host.

Installed packages:

- unattended-upgrades