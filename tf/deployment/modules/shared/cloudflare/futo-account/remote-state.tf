data "terraform_remote_state" "futo_api_keys_state" {
  backend = "pg"

  config = {
    conn_str    = var.tf_state_postgres_conn_str
    schema_name = "prod_cloudflare_futo_api_keys"
  }
}
