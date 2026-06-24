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
