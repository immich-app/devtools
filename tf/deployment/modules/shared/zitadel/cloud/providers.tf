provider "zitadel" {
  domain           = "auth.internal.futo.org"
  insecure         = false
  jwt_profile_json = var.futo_zitadel_profile_json
}

provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}
