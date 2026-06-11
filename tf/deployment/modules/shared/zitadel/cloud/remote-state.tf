// Cloudflare account API token (with Workers Scripts perms) for deploying the
// zitadel-actions worker. Sourced from the cloudflare api-keys module's state,
// same as the cloudflare/account module does.
data "terraform_remote_state" "api_keys_state" {
  backend = "pg"

  config = {
    conn_str    = var.tf_state_postgres_conn_str
    schema_name = "prod_cloudflare_api_keys"
  }
}
