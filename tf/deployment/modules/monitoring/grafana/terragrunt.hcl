terraform {
  source = "../../../../"

  extra_arguments custom_vars {
    commands = get_terraform_commands_that_need_vars()
  }
}

dependencies {
  paths = [
    "../../discord",
  ]
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}
