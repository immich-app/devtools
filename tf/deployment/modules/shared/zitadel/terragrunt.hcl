terraform {
  source = "."

  extra_arguments custom_vars {
    commands = get_terraform_commands_that_need_vars()
  }

  include_in_copy = ["repo-files/*"]
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  users_data_file_path = "${get_repo_root()}/tf/deployment/data/users.json"
}

dependencies {
  paths = []
}
