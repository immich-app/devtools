provider "cloudflare" {
  api_token = data.terraform_remote_state.api_keys_state.outputs.terraform_key_cloudflare_account
}

provider "cloudflare" {
  alias     = "api_keys"
  api_token = var.cloudflare_api_token
}

provider "onepassword" {
  service_account_token = var.op_service_account_token
}
