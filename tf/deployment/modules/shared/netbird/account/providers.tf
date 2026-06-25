provider "netbird" {
  token          = data.onepassword_item.netbird_pat.password
  management_url = "https://api.netbird.io"
}

# FUTO 1Password account, used to read the NetBird PAT from the shared_tf vault.
# The service-account token is resolved from the immich account via op run, which
# bridges to the FUTO account — the op CLI cannot reach it directly.
provider "onepassword" {
  service_account_token = var.futo_op_service_account_token
}
