terraform {
  source = "."

  extra_arguments custom_vars {
    commands = get_terraform_commands_that_need_vars()
  }
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependencies {
  paths = ["../../cloudflare/api-keys", "../../cloudflare/account", "../../1password/account", "../../docker/org"]
}
