provider "cloudflare" {
  api_token = data.terraform_remote_state.futo_api_keys_state.outputs.terraform_key_futo_cloudflare_account
}

provider "onepassword" {
  service_account_token = var.futo_op_service_account_token
}
