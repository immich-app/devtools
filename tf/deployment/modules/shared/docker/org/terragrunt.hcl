terraform {
  source = "."

  extra_arguments custom_vars {
    commands = get_terraform_commands_that_need_vars()
  }
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Temporarily excluded. Docker Hub serves a Cloudflare bot challenge to the
# provider's API client, so reading any docker_hub_repository fails with an
# HTML "Just a moment..." body instead of JSON. The endpoints are the
# documented ones — this is Docker's WAF against Docker's own provider.
#
# Upstream: https://github.com/docker/terraform-provider-docker/issues/144
# Reproduces on provider 0.7.0 as well, so bumping the version is not a fix.
#
# Remove this block once the provider can talk to the API again.
exclude {
  if      = true
  actions = ["all"]
}
