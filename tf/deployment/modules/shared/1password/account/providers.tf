provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}

# Second 1Password account (FUTO), used to mirror the github app credentials
# into the FUTO shared_tf vault alongside the immich tf copy.
provider "onepassword" {
  alias                 = "futo"
  service_account_token = var.futo_op_service_account_token
}

# The immich_* vaults in the FUTO account are written through immich's own
# Connect server, not a service account: service accounts exist only to pull the
# original secrets into .env files. Same shape as the immich-account Connect
# provider above, pointed at the per-project Connect server instead.
provider "onepassword" {
  alias = "futo_immich"
  url   = var.futo_immich_op_connect_url
  token = var.futo_immich_op_connect_token
}
