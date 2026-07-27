# Connect via the stable <name>.zitadel.cloud base domain, not the auth.futo.cloud
# vanity domain (CUSTOMER_ZITADEL_DOMAIN) which is an alias that could change.
provider "zitadel" {
  domain           = data.onepassword_item.customer_zitadel_base_domain.password
  insecure         = false
  jwt_profile_json = data.onepassword_item.customer_zitadel_profile_json.password
}

provider "onepassword" {
  service_account_token = var.futo_op_service_account_token
}

provider "cloudflare" {
  api_token = data.terraform_remote_state.futo_cloudflare_api_keys.outputs.terraform_key_futo_cloudflare_account
}
