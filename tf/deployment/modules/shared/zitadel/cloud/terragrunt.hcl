terraform {
  source = "."

  extra_arguments custom_vars {
    commands = get_terraform_commands_that_need_vars()
  }

  include_in_copy = ["repo-files/*", "scripts/*", "assets/*", "translations/*"]
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  users_data_file_path         = "${get_repo_root()}/tf/deployment/data/users.json"
  zitadel_actions_worker_dir   = "${get_repo_root()}/services/zitadel-actions"
  outline_role_sync_worker_dir = "${get_repo_root()}/services/outline-role-sync"
}

dependencies {
  paths = ["../../cloudflare/api-keys"]
}
