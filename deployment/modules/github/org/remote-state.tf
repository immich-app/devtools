data "terraform_remote_state" "api_keys_state" {
  backend = "pg"

  config = {
    conn_str    = var.tf_state_postgres_conn_str
    schema_name = "prod_cloudflare_api_keys"
  }
}

data "onepassword_vault" "opentofu_vault" {
  name = "OpenTofu"
}

data "onepassword_vault" "kubernetes" {
  name = "Kubernetes"
}

data "onepassword_vault" "github" {
  name = "Github"
}
