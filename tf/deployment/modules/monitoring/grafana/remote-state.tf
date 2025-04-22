data "terraform_remote_state" "discord_state" {
  backend = "pg"

  config = {
    conn_str    = var.tf_state_postgres_conn_str
    schema_name = "prod_discord_community"
  }
}
