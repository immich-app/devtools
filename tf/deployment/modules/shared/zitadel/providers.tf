provider "zitadel" {
  domain           = "zitadel.internal.immich.cloud"
  insecure         = false
  jwt_profile_json = var.zitadel_profile_json
}

provider "onepassword" {
  url   = var.op_connect_url
  token = var.op_connect_token
}
