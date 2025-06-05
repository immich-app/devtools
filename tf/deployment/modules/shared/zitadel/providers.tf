provider "zitadel" {
  domain           = "zitadel.internal.immich.cloud"
  insecure         = false
  jwt_profile_json = var.zitadel_profile_json
}

provider "onepassword" {
  service_account_token = var.op_service_account_token
}
