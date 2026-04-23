provider "zitadel" {
  domain           = data.onepassword_item.customer_zitadel_domain.password
  insecure         = false
  jwt_profile_json = data.onepassword_item.customer_zitadel_profile_json.password
}

provider "onepassword" {
  service_account_token = var.futo_op_service_account_token
}
