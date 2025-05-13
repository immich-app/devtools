# Devtools

This repository holds various tooling used by the Immich maintainer team. 
That includes tofu modules, as well as kubernetes manifests for a Hetzner-hosted dedicated machine used for builds and testing environments.

## Mise

This repository uses mise for managing the development environment. After installing and activating mise, most things should Just Work™.  
You can list the available tasks with `mise task ls`.

Secrets are managed through the 1password cli. You can activate it with `op account add` and then `eval $(op signin)`.

After that is set up, any terraform commands can be run through `mise run tf <command>`.  
Kubectl is set up to get secrets from onepassword and should work out of the box while you're in this folder.
