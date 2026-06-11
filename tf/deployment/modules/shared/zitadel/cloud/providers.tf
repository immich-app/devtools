provider "zitadel" {
  domain           = "auth.internal.futo.org"
  insecure         = false
  jwt_profile_json = var.futo_zitadel_profile_json
}

provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}

provider "cloudflare" {
  api_token = data.terraform_remote_state.api_keys_state.outputs.terraform_key_cloudflare_account
}
