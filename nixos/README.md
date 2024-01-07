# Nixos

This folder holds the nixos configuration intended to bootstrap the dedicated server used by the maintainer team.
All the management of containers and such is done via Kubernetes on top of this.

I couldn't get this config to come up successfully, so it's not actually used right now.

### Bootstrap

Start up the remote machine with the Hetzner recovery image, then run the following command inside this folder:

```
nix run github:nix-community/nixos-anywhere -- --flake .#hetzner --build-on-remote root@mich
```
