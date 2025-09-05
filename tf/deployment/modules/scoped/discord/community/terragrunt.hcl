terraform {
  source = "."

  extra_arguments custom_vars {
    commands = get_terraform_commands_that_need_vars()
  }

  extra_arguments parallism {
    commands  = ["apply"]
    arguments = ["-parallelism=1"]
  }
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

inputs = {
  users_data_file_path = "${get_repo_root()}/tf/deployment/data/users.json"
}

locals {
  env                        = get_env("TF_VAR_env")
  tf_state_postgres_conn_str = get_env("TF_VAR_tf_state_postgres_conn_str")
}

remote_state {
  backend = "pg"

  config = {
    conn_str    = local.tf_state_postgres_conn_str
    schema_name = "${local.env}_discord_community"
  }
}
