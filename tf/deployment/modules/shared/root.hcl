locals {
  tf_state_postgres_conn_str = get_env("TF_VAR_tf_state_postgres_conn_str")
}

remote_state {
  backend = "pg"

  config = {
    conn_str = local.tf_state_postgres_conn_str
  }
}

terraform {
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=5m"]
  }
}
