# VolSync Template

## Flux Kustomization

This requires `postBuild` configured on the Flux Kustomization

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: &app immich
  namespace: flux-system
spec:
  targetNamespace: default
  path: ./kubernetes/apps/default/immich/app
  prune: true
  sourceRef:
    kind: GitRepository
    name: kubernetes
  wait: false
  interval: 30m
  retryInterval: 1m
  timeout: 5m
  postBuild:
    substitute:
      APP: *app
      VOLSYNC_CAPACITY: 1Gi
      VOLSYNC_REPO_SECRET: immich-volsync
```

Then reference this template in the kustomization.yaml

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ./hr.yaml
  - ./pvc.yaml
  - ../../../../../templates/volsync
```

## Required `postBuild` vars:

- `APP`: The application name
- `VOLSYNC_CAPACITY`: The PVC size
- `VOLSYNC_SECRET_STORE`: The name of the ClusterSecretStore to use 
- `VOLSYNC_RESTIC_PASSWORD_SECRET`: The name of the 1password entry holding the restic password
- `VOLSYNC_BUCKET_SECRET`: The name of the 1password entry holding the bucket credentials
