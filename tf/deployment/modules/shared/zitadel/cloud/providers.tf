# Connect via the stable <name>.zitadel.cloud base domain, not the
# auth.internal.futo.org custom domain which is a mutable alias.
provider "zitadel" {
  domain           = var.futo_zitadel_base_domain
  insecure         = false
  jwt_profile_json = var.futo_zitadel_profile_json
}

provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}

# Second 1Password account (FUTO), used to mirror the zitadel OIDC client
# credentials into the FUTO shared_tf vault alongside the immich tf copy.
provider "onepassword" {
  alias                 = "futo"
  service_account_token = var.futo_op_service_account_token
}

provider "cloudflare" {
  api_token = data.terraform_remote_state.api_keys_state.outputs.terraform_key_cloudflare_account
}
