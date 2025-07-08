data "terraform_remote_state" "api_keys_state" {
  backend = "pg"

  config = {
    conn_str    = var.tf_state_postgres_conn_str
    schema_name = "prod_cloudflare_api_keys"
  }
}

data "terraform_remote_state" "docker_org_state" {
  backend = "pg"

  config = {
    conn_str    = var.tf_state_postgres_conn_str
    schema_name = "prod_docker_org"
  }
}

data "terraform_remote_state" "cloudflare_account" {
  backend = "pg"

  config = {
    conn_str    = var.tf_state_postgres_conn_str
    schema_name = "prod_cloudflare_account"
  }
}

data "onepassword_vault" "github" {
  name = "Github"
}
