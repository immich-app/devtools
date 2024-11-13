terraform {
  source = "."

  extra_arguments custom_vars {
    commands = get_terraform_commands_that_need_vars()
  }
}

include "cloudflare" {
  path = find_in_parent_folders("cloudflare.hcl")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}
